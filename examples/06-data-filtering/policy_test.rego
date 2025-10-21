package filtering

import rego.v1

# ================================================================
# Data Filtering Policy - Test Suite
# ================================================================

# Mock数据
mock_records := [
	# Tenant A数据
	{
		"id": "rec-001",
		"tenant_id": "tenant-a",
		"team_id": "team-1",
		"owner_id": "user-1",
		"title": "Project Alpha",
		"content": "Sensitive content",
		"metadata": {"department": "engineering"},
		"shared_with": ["user-2"],
		"is_public": false,
		"created_at": "2025-01-01T00:00:00Z",
	},
	{
		"id": "rec-002",
		"tenant_id": "tenant-a",
		"team_id": "team-1",
		"owner_id": "user-2",
		"title": "Project Beta",
		"content": "More content",
		"metadata": {"department": "engineering"},
		"shared_with": [],
		"is_public": false,
		"created_at": "2025-01-02T00:00:00Z",
	},
	{
		"id": "rec-003",
		"tenant_id": "tenant-a",
		"team_id": "team-2",
		"owner_id": "user-3",
		"title": "Project Gamma",
		"content": "Team 2 content",
		"metadata": {"department": "sales"},
		"shared_with": [],
		"is_public": false,
		"created_at": "2025-01-03T00:00:00Z",
	},
	# Tenant B数据
	{
		"id": "rec-004",
		"tenant_id": "tenant-b",
		"team_id": "team-3",
		"owner_id": "user-4",
		"title": "Project Delta",
		"content": "Different tenant",
		"metadata": {"department": "ops"},
		"shared_with": [],
		"is_public": false,
		"created_at": "2025-01-04T00:00:00Z",
	},
	# 公开数据
	{
		"id": "rec-005",
		"tenant_id": "tenant-a",
		"team_id": "team-1",
		"owner_id": "user-1",
		"title": "Public Announcement",
		"content": "Public content",
		"metadata": {},
		"shared_with": [],
		"is_public": true,
		"created_at": "2025-01-05T00:00:00Z",
	},
]

# ────────────────────────────────────────────────────────────────
# 测试：全局管理员
# ────────────────────────────────────────────────────────────────

test_admin_sees_all_records if {
	records := allowed_records with input as {
		"user": {
			"id": "admin-1",
			"role": "admin",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	count(records) == count(mock_records)
}

test_admin_accesses_cross_tenant if {
	records := allowed_records with input as {
		"user": {
			"id": "admin-1",
			"role": "admin",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	# 验证有Tenant B的数据
	some r in records
	r.tenant_id == "tenant-b"
}

# ────────────────────────────────────────────────────────────────
# 测试：租户管理员
# ────────────────────────────────────────────────────────────────

test_tenant_admin_sees_own_tenant_only if {
	records := allowed_records with input as {
		"user": {
			"id": "tenant-admin-1",
			"role": "tenant_admin",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	# 只看到tenant-a的数据
	count(records) == 4 # rec-001, rec-002, rec-003, rec-005
	every r in records {
		r.tenant_id == "tenant-a"
	}
}

test_tenant_admin_cannot_see_other_tenant if {
	records := allowed_records with input as {
		"user": {
			"id": "tenant-admin-1",
			"role": "tenant_admin",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	# 确保没有tenant-b的数据
	not some r in records
	r.tenant_id == "tenant-b"
}

# ────────────────────────────────────────────────────────────────
# 测试：团队管理员
# ────────────────────────────────────────────────────────────────

test_team_manager_sees_team_records if {
	records := allowed_records with input as {
		"user": {
			"id": "team-manager-1",
			"role": "user",
			"tenant_id": "tenant-a",
			"team_id": "team-1",
			"is_team_manager": true,
		},
	}
		with data.records as mock_records

	# 看到team-1的数据
	count(records) == 3 # rec-001, rec-002, rec-005 (public)
	every r in records {
		r.team_id == "team-1" or r.is_public == true
	}
}

test_team_manager_cannot_see_other_teams if {
	records := allowed_records with input as {
		"user": {
			"id": "team-manager-1",
			"role": "user",
			"tenant_id": "tenant-a",
			"team_id": "team-1",
			"is_team_manager": true,
		},
	}
		with data.records as mock_records

	# 确保没有team-2的数据
	not some r in records
	r.team_id == "team-2"
	r.is_public == false
}

# ────────────────────────────────────────────────────────────────
# 测试：普通用户
# ────────────────────────────────────────────────────────────────

test_user_sees_own_records_only if {
	records := allowed_records with input as {
		"user": {
			"id": "user-1",
			"role": "user",
			"tenant_id": "tenant-a",
			"team_id": "team-1",
			"is_team_manager": false,
		},
	}
		with data.records as mock_records

	# user-1拥有rec-001和rec-005，没有其他
	count(records) == 2
	every r in records {
		r.owner_id == "user-1" or r.is_public == true
	}
}

test_user_sees_shared_records if {
	records := allowed_records with input as {
		"user": {
			"id": "user-2",
			"role": "user",
			"tenant_id": "tenant-a",
			"team_id": "team-1",
			"is_team_manager": false,
		},
	}
		with data.records as mock_records

	# user-2拥有rec-002，rec-001分享给他，rec-005公开
	count(records) == 3

	# 验证rec-001被分享给user-2
	some r in records
	r.id == "rec-001"
	"user-2" in r.shared_with
}

test_user_cannot_access_other_user_records if {
	records := allowed_records with input as {
		"user": {
			"id": "user-3",
			"role": "user",
			"tenant_id": "tenant-a",
			"team_id": "team-2",
			"is_team_manager": false,
		},
	}
		with data.records as mock_records

	# 确保user-3看不到team-1的私有数据
	not some r in records
	r.team_id == "team-1"
	r.is_public == false
	r.owner_id != "user-3"
}

# ────────────────────────────────────────────────────────────────
# 测试：租户隔离
# ────────────────────────────────────────────────────────────────

test_tenant_isolation_enforced if {
	tenant_isolated with input as {
		"user": {
			"id": "user-1",
			"role": "user",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records
}

test_cross_tenant_access_denied if {
	records := allowed_records with input as {
		"user": {
			"id": "user-1",
			"role": "user",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	# 确保没有tenant-b的数据
	not some r in records
	r.tenant_id == "tenant-b"
}

# ────────────────────────────────────────────────────────────────
# 测试：公开数据
# ────────────────────────────────────────────────────────────────

test_public_records_accessible_to_all if {
	records := allowed_records with input as {
		"user": {
			"id": "guest-1",
			"role": "guest",
			"tenant_id": "tenant-c",
		},
	}
		with data.records as mock_records

	# guest能看到公开数据
	some r in records
	r.is_public == true
}

# ────────────────────────────────────────────────────────────────
# 测试：数据脱敏
# ────────────────────────────────────────────────────────────────

test_admin_sees_full_data if {
	records := filtered_records with input as {
		"user": {
			"id": "admin-1",
			"role": "admin",
		},
	}
		with data.records as [mock_records[0]]

	# 管理员看到完整数据
	some r in records
	r.content == "Sensitive content"
	r.metadata.department == "engineering"
}

test_user_sees_sanitized_data if {
	records := filtered_records with input as {
		"user": {
			"id": "user-1",
			"role": "user",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as [mock_records[0]]

	# 普通用户看不到敏感字段
	some r in records
	not r.content
	not r.metadata
	r.title == "Project Alpha"
}

# ────────────────────────────────────────────────────────────────
# 测试：SQL生成
# ────────────────────────────────────────────────────────────────

test_sql_where_for_admin if {
	sql_where_clause == "1 = 1" with input as {"user": {"role": "admin"}}
}

test_sql_where_for_tenant_admin if {
	clause := sql_where_clause with input as {
		"user": {
			"role": "tenant_admin",
			"tenant_id": "tenant-a",
		},
	}

	clause == "tenant_id = 'tenant-a'"
}

test_sql_where_for_user if {
	clause := sql_where_clause with input as {
		"user": {
			"role": "user",
			"id": "user-1",
			"tenant_id": "tenant-a",
		},
	}

	contains(clause, "owner_id = 'user-1'")
	contains(clause, "'user-1' = ANY(shared_with)")
}

# ────────────────────────────────────────────────────────────────
# 测试：统计
# ────────────────────────────────────────────────────────────────

test_record_count if {
	count := record_count with input as {
		"user": {
			"id": "user-1",
			"role": "user",
			"tenant_id": "tenant-a",
		},
	}
		with data.records as mock_records

	count == 2 # user-1的记录
}

test_records_by_tenant if {
	stats := records_by_tenant with input as {
		"user": {
			"role": "admin",
		},
	}
		with data.records as mock_records

	stats["tenant-a"] == 4
	stats["tenant-b"] == 1
}

