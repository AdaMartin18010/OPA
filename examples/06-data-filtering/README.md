# 数据过滤示例：行级权限控制

> **难度**: ⭐⭐⭐⭐⭐ 高级  
> **学习时间**: 90-120分钟  
> **场景**: 数据访问控制、行级安全、多租户隔离  
> **前置知识**: RBAC、SQL、数据过滤概念

---

## 📖 场景说明

本示例展示如何使用OPA实现**行级权限控制（Row-Level Security, RLS）**，确保用户只能访问他们有权限的数据行。

### 典型应用场景

- **SaaS多租户**: 租户只能看到自己的数据
- **部门隔离**: 员工只能访问本部门数据
- **项目权限**: 用户只能访问参与的项目数据
- **数据市场**: 购买者只能访问已购买的数据集

---

## 🎯 权限模型

### 权限层次

```text
┌────────────────────────────────────────────────────────────┐
│ 1. 全局管理员 (Global Admin)                               │
│    ✅ 可以看到所有数据                                      │
└────────────────────────────────────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────────┐
│ 2. 租户管理员 (Tenant Admin)                               │
│    ✅ 可以看到本租户的所有数据                              │
│    ❌ 不能看到其他租户的数据                                 │
└────────────────────────────────────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────────┐
│ 3. 团队管理员 (Team Manager)                               │
│    ✅ 可以看到本团队的数据                                  │
│    ✅ 可以看到团队成员的数据                                 │
└────────────────────────────────────────────────────────────┘
                            │
┌────────────────────────────────────────────────────────────┐
│ 4. 普通用户 (User)                                         │
│    ✅ 只能看到自己创建的数据                                 │
│    ✅ 只能看到明确分享给他的数据                             │
└────────────────────────────────────────────────────────────┘
```

---

## 📦 文件清单

```bash
06-data-filtering/
├── README.md                    # 本文档
├── policy.rego                  # 数据过滤策略
├── policy_test.rego             # 单元测试
├── data.json                    # 模拟数据库数据
├── input_admin.json             # 管理员查询示例
├── input_user.json              # 普通用户查询示例
├── input_team.json              # 团队查询示例
└── demo.sh                      # 演示脚本
```

---

## 🚀 快速开始

### 1. 本地测试策略

```bash
cd examples/06-data-filtering

# 运行单元测试
opa test . -v

# 预期：✅ 50+ tests passed
```

### 2. 交互式查询

```bash
# 启动REPL
opa run policy.rego data.json

# 查询允许的数据
> data.filtering.allowed_records
```

### 3. 运行演示

```bash
# 演示不同角色的数据访问
bash demo.sh
```

---

## 📊 数据模型

### 数据库记录示例

```json
{
  "records": [
    {
      "id": "rec-001",
      "tenant_id": "tenant-a",
      "team_id": "team-1",
      "owner_id": "user-1",
      "title": "Project Alpha",
      "content": "Sensitive project data...",
      "shared_with": ["user-2"],
      "created_at": "2025-01-01T00:00:00Z"
    },
    {
      "id": "rec-002",
      "tenant_id": "tenant-a",
      "team_id": "team-1",
      "owner_id": "user-2",
      "title": "Project Beta",
      "content": "Another project...",
      "shared_with": [],
      "created_at": "2025-01-02T00:00:00Z"
    }
  ]
}
```

### 用户上下文

```json
{
  "user": {
    "id": "user-1",
    "role": "user",
    "tenant_id": "tenant-a",
    "team_id": "team-1",
    "is_team_manager": false
  }
}
```

---

## 📝 策略详解

### 核心过滤逻辑

```rego
# 用户可以访问的记录
allowed_records[record] {
    some record in data.records
    can_access_record(record)
}

# 访问权限判断
can_access_record(record) {
    # 1. 全局管理员可以访问所有数据
    input.user.role == "admin"
}

can_access_record(record) {
    # 2. 租户管理员可以访问本租户数据
    input.user.role == "tenant_admin"
    input.user.tenant_id == record.tenant_id
}

can_access_record(record) {
    # 3. 团队管理员可以访问本团队数据
    input.user.is_team_manager
    input.user.team_id == record.team_id
}

can_access_record(record) {
    # 4. 用户可以访问自己的数据
    input.user.id == record.owner_id
}

can_access_record(record) {
    # 5. 用户可以访问分享给他的数据
    input.user.id in record.shared_with
}
```

### 数据脱敏

对于敏感字段，可以根据权限脱敏：

```rego
# 过滤并脱敏记录
filtered_records := [sanitized_record(r) | r := allowed_records[_]]

# 脱敏函数
sanitized_record(record) := sanitized {
    # 管理员看到完整数据
    input.user.role == "admin"
    sanitized := record
}

sanitized_record(record) := sanitized {
    # 普通用户看到脱敏数据
    input.user.role != "admin"
    sanitized := object.remove(record, ["content", "metadata"])
}
```

---

## 🧪 测试用例

### 测试1：管理员访问所有数据

```rego
test_admin_sees_all_records {
    records := allowed_records with input as {
        "user": {
            "id": "admin-1",
            "role": "admin",
            "tenant_id": "tenant-a"
        }
    } with data.records as mock_records
    
    count(records) == count(mock_records)
}
```

### 测试2：用户只看到自己的数据

```rego
test_user_sees_own_records_only {
    records := allowed_records with input as {
        "user": {
            "id": "user-1",
            "role": "user",
            "tenant_id": "tenant-a",
            "team_id": "team-1"
        }
    } with data.records as mock_records
    
    # 验证每条记录都属于user-1
    every record in records {
        record.owner_id == "user-1" or
        "user-1" in record.shared_with
    }
}
```

### 测试3：租户隔离

```rego
test_tenant_isolation {
    records := allowed_records with input as {
        "user": {
            "id": "user-1",
            "role": "user",
            "tenant_id": "tenant-a"
        }
    } with data.records as mock_records
    
    # 确保没有其他租户的数据泄露
    every record in records {
        record.tenant_id == "tenant-a"
    }
}
```

---

## 🔧 实际应用

### 集成到REST API

```python
# Python Flask示例
@app.route('/api/records')
@require_auth
def get_records():
    # 1. 获取用户上下文
    user_context = {
        "user": {
            "id": current_user.id,
            "role": current_user.role,
            "tenant_id": current_user.tenant_id,
            "team_id": current_user.team_id
        }
    }
    
    # 2. 查询数据库（获取所有数据）
    all_records = db.query("SELECT * FROM records")
    
    # 3. OPA过滤
    opa_input = {
        **user_context,
        "records": all_records
    }
    
    result = opa.evaluate("filtering.allowed_records", opa_input)
    filtered_records = result["result"]
    
    # 4. 返回过滤后的数据
    return jsonify(filtered_records)
```

### 集成到SQL查询

生成动态WHERE子句：

```rego
# 生成SQL WHERE条件
sql_where_clause := clause {
    input.user.role == "admin"
    clause := "1=1"  # 无限制
}

sql_where_clause := clause {
    input.user.role == "user"
    clause := sprintf("owner_id = '%s' OR '%s' = ANY(shared_with)", [
        input.user.id,
        input.user.id
    ])
}

sql_where_clause := clause {
    input.user.role == "tenant_admin"
    clause := sprintf("tenant_id = '%s'", [input.user.tenant_id])
}
```

使用：

```python
# 构建动态查询
where_clause = opa.evaluate("filtering.sql_where_clause", user_context)
query = f"SELECT * FROM records WHERE {where_clause}"
results = db.execute(query)
```

---

## 📊 性能考虑

### 方案对比

| 方案 | 优点 | 缺点 | 适用场景 |
|---|---|---|---|
| **应用层过滤** | 灵活、易调试 | 性能差（查询所有数据） | 小数据量 (<10K行) |
| **SQL WHERE生成** | 性能好（数据库过滤） | 复杂查询难实现 | 中等数据量 (<1M行) |
| **数据库RLS** | 性能最优、安全 | 配置复杂、迁移难 | 大数据量 (1M+行) |
| **混合方案** | 平衡性能和灵活性 | 架构复杂 | 生产环境推荐 |

### 优化建议

1. **使用SQL生成**: 将过滤逻辑下推到数据库
2. **缓存决策**: 对于相同用户的连续查询，缓存权限决策
3. **预计算**: 对于复杂权限，预计算并存储在用户session
4. **批量查询**: 一次决策多个记录，减少OPA调用

---

## 🎯 高级功能

### 1. 字段级权限

不同角色看到不同字段：

```rego
allowed_fields := fields {
    input.user.role == "admin"
    fields := {"*"}  # 所有字段
}

allowed_fields := fields {
    input.user.role == "user"
    fields := {"id", "title", "created_at"}  # 受限字段
}
```

### 2. 时间范围过滤

根据时间限制数据访问：

```rego
can_access_record(record) {
    # 用户只能访问最近30天的数据
    input.user.role == "user"
    record_time := time.parse_rfc3339_ns(record.created_at)
    now := time.now_ns()
    diff_days := (now - record_time) / (1000000000 * 60 * 60 * 24)
    diff_days <= 30
}
```

### 3. 动态权限加载

从外部系统加载权限：

```rego
# 从API加载用户权限
user_permissions := http.send({
    "method": "GET",
    "url": sprintf("https://authz-api/users/%s/permissions", [input.user.id]),
    "headers": {"Authorization": "Bearer XXX"}
}).body

can_access_record(record) {
    record.id in user_permissions.allowed_records
}
```

---

## 📚 扩展练习

### 练习1：添加审计日志

记录每次数据访问：

```rego
# 生成审计日志
audit_log := {
    "user_id": input.user.id,
    "action": "read",
    "records_accessed": [r.id | r := allowed_records[_]],
    "timestamp": time.now_ns(),
    "ip_address": input.source_ip
}
```

### 练习2：实现数据加密

对于敏感字段，返回加密后的值：

```rego
encrypted_records := [encrypt_record(r) | r := allowed_records[_]]

encrypt_record(record) := encrypted {
    input.user.role != "admin"
    encrypted := object.union(
        object.remove(record, ["ssn", "credit_card"]),
        {
            "ssn": mask_ssn(record.ssn),
            "credit_card": mask_card(record.credit_card)
        }
    )
}
```

### 练习3：复杂分享权限

实现类似Google Docs的分享机制：

```json
{
  "sharing": {
    "rec-001": {
      "public": false,
      "users": {
        "user-2": "view",
        "user-3": "edit"
      },
      "teams": {
        "team-2": "view"
      }
    }
  }
}
```

---

## 🏭 生产部署

### 1. 数据源集成

```yaml
# OPA配置：从数据库加载权限
bundles:
  authz:
    service: database_service
    resource: /v1/data
    polling:
      min_delay_seconds: 30
      max_delay_seconds: 60
```

### 2. 监控指标

```prometheus
# 关键指标
opa_filtering_records_total     # 过滤的记录总数
opa_filtering_duration_ms       # 过滤耗时
opa_filtering_denied_access     # 拒绝访问次数
```

### 3. 审计合规

- **记录所有访问**: 谁在什么时候访问了哪些数据
- **异常检测**: 异常访问模式（大量数据导出）
- **合规报告**: GDPR、HIPAA等合规要求

---

## 🔗 相关资源

- [访问控制(RBAC)文档](../../docs/05-应用场景/05.1-访问控制(RBAC).md)
- [SaaS多租户实战](../../docs/09-生产实战/09.3-SaaS多租户WASM实战.md)
- [性能优化指南](../../docs/08-最佳实践/08.2-性能优化指南.md)

---

## 📝 总结

本示例展示了：

✅ **行级权限控制**: 细粒度数据访问控制  
✅ **多租户隔离**: SaaS应用的数据隔离  
✅ **团队权限**: 层次化的权限模型  
✅ **数据脱敏**: 根据权限级别脱敏敏感数据  
✅ **SQL集成**: 动态生成WHERE子句  
✅ **性能优化**: 数据库过滤vs应用层过滤

**关键收获**:

- 理解行级安全（RLS）的重要性
- 掌握多种数据过滤实现方式
- 学习SaaS多租户数据隔离
- 了解性能优化的权衡

---

**下一步**: 尝试集成到你的应用，实现真实的数据过滤功能！

🎓 **学习建议**: 先理解策略逻辑，再尝试集成到REST API，最后优化性能。
