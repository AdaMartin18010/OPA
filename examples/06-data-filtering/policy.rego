package filtering

import rego.v1

# ================================================================
# Data Filtering Policy - Row-Level Security
# 场景: 行级权限控制、多租户数据隔离、团队权限
# ================================================================

# ────────────────────────────────────────────────────────────────
# 主决策：用户可以访问的记录
# ────────────────────────────────────────────────────────────────

# 返回用户有权访问的所有记录
allowed_records contains record if {
	some record in data.records
	can_access_record(record)
}

# ────────────────────────────────────────────────────────────────
# 访问权限判断
# ────────────────────────────────────────────────────────────────

# 1. 全局管理员可以访问所有数据
can_access_record(_) if {
	input.user.role == "admin"
}

# 2. 租户管理员可以访问本租户的所有数据
can_access_record(record) if {
	input.user.role == "tenant_admin"
	input.user.tenant_id == record.tenant_id
}

# 3. 团队管理员可以访问本团队的数据
can_access_record(record) if {
	input.user.is_team_manager == true
	input.user.team_id == record.team_id
}

# 4. 用户可以访问自己创建的数据
can_access_record(record) if {
	input.user.role == "user"
	input.user.id == record.owner_id
}

# 5. 用户可以访问分享给他的数据
can_access_record(record) if {
	input.user.role == "user"
	input.user.id in record.shared_with
}

# 6. 公开数据（所有人可访问）
can_access_record(record) if {
	record.is_public == true
}

# ────────────────────────────────────────────────────────────────
# 租户隔离检查
# ────────────────────────────────────────────────────────────────

# 验证用户只能访问本租户数据（除非是全局管理员）
tenant_isolated if {
	input.user.role == "admin" # 管理员无租户限制
}

tenant_isolated if {
	input.user.role != "admin"
	every record in allowed_records {
		record.tenant_id == input.user.tenant_id
	}
}

# ────────────────────────────────────────────────────────────────
# 数据脱敏
# ────────────────────────────────────────────────────────────────

# 返回过滤并脱敏后的记录
filtered_records := [sanitized_record(r) | some r in allowed_records]

# 脱敏规则：管理员看完整数据，普通用户看脱敏数据
sanitized_record(record) := record if {
	input.user.role == "admin"
}

sanitized_record(record) := sanitized if {
	input.user.role != "admin"
	sanitized := {
		"id": record.id,
		"title": record.title,
		"owner_id": record.owner_id,
		"created_at": record.created_at,
		# 移除敏感字段
		# "content", "metadata" 被过滤
	}
}

# ────────────────────────────────────────────────────────────────
# SQL WHERE子句生成（用于数据库查询优化）
# ────────────────────────────────────────────────────────────────

sql_where_clause := "1 = 1" if {
	input.user.role == "admin"
}

sql_where_clause := clause if {
	input.user.role == "tenant_admin"
	clause := sprintf("tenant_id = '%s'", [input.user.tenant_id])
}

sql_where_clause := clause if {
	input.user.is_team_manager == true
	clause := sprintf("tenant_id = '%s' AND team_id = '%s'", [
		input.user.tenant_id,
		input.user.team_id,
	])
}

sql_where_clause := clause if {
	input.user.role == "user"
	clause := sprintf(
		"tenant_id = '%s' AND (owner_id = '%s' OR '%s' = ANY(shared_with))",
		[input.user.tenant_id, input.user.id, input.user.id],
	)
}

# ────────────────────────────────────────────────────────────────
# 统计信息
# ────────────────────────────────────────────────────────────────

# 统计可访问的记录数
record_count := count(allowed_records)

# 按租户统计
records_by_tenant[tenant_id] := count if {
	tenant_records := [r | some r in allowed_records; r.tenant_id == tenant_id]
	count := count(tenant_records)
}

# 按团队统计
records_by_team[team_id] := count if {
	team_records := [r | some r in allowed_records; r.team_id == team_id]
	count := count(team_records)
}

# ────────────────────────────────────────────────────────────────
# 审计日志
# ────────────────────────────────────────────────────────────────

audit_log := {
	"user_id": input.user.id,
	"role": input.user.role,
	"tenant_id": input.user.tenant_id,
	"action": "query_records",
	"records_count": record_count,
	"timestamp": time.now_ns(),
	"filtered": input.user.role != "admin",
}

