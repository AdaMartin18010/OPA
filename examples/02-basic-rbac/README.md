# 示例02：基础RBAC（角色访问控制）

> **难度**: ⭐⭐ 入门  
> **场景**: 应用级别的角色权限控制  
> **学习时间**: 20-30分钟  
> **适用版本**: OPA v1.4.0 | Rego v1.0  
> **测试版本**: OPA v1.4.0  
> **最后验证**: 2026-03-19

---

## 📋 场景说明

实现一个简单的基于角色的访问控制（RBAC）系统，支持：

- 3种角色：`admin`、`editor`、`viewer`
- 4种操作：`read`、`write`、`delete`、`admin`
- 权限继承：admin > editor > viewer

### 权限矩阵

| 角色 | read | write | delete | admin |
|---|---|---|---|---|
| **admin** | ✅ | ✅ | ✅ | ✅ |
| **editor** | ✅ | ✅ | ❌ | ❌ |
| **viewer** | ✅ | ❌ | ❌ | ❌ |

---

## 📁 文件说明

- `policy.rego`: RBAC策略定义
- `policy_test.rego`: 完整的单元测试（覆盖所有角色和操作）
- `input_admin.json`: Admin用户的输入示例
- `input_editor.json`: Editor用户的输入示例
- `input_viewer.json`: Viewer用户的输入示例
- `data.json`: 角色权限配置（可扩展）

---

## 🚀 快速运行

### 1. 测试所有场景

```bash
cd examples/02-basic-rbac
opa test . -v
```

预期输出：

```text
data.rbac.test_admin_can_read: PASS (0.5ms)
data.rbac.test_admin_can_write: PASS (0.4ms)
data.rbac.test_admin_can_delete: PASS (0.3ms)
data.rbac.test_editor_can_read: PASS (0.3ms)
data.rbac.test_editor_can_write: PASS (0.3ms)
data.rbac.test_editor_cannot_delete: PASS (0.3ms)
data.rbac.test_viewer_can_read: PASS (0.3ms)
data.rbac.test_viewer_cannot_write: PASS (0.3ms)
--------------------------------------------------------------------------------
PASS: 8/8
```

### 2. 测试Admin权限

```bash
opa eval -i input_admin.json -d policy.rego -d data.json "data.rbac.allow"
```

预期输出：

```json
{
  "result": [
    {
      "expressions": [
        {
          "value": true,
          "text": "data.rbac.allow",
          "location": {
            "row": 1,
            "col": 1
          }
        }
      ]
    }
  ]
}
```

### 3. 测试Viewer写权限（应被拒绝）

```bash
opa eval -i input_viewer.json -d policy.rego -d data.json "data.rbac.allow" --format pretty
```

预期输出：

```text
false
```

---

## 📖 核心概念

### 1. 默认拒绝（Default Deny）

```rego
package rbac

import rego.v1

# 默认拒绝所有请求
default allow := false
```

**最佳实践**：安全系统应默认拒绝，显式授权。

### 2. 角色权限查询

```rego
# 获取用户角色的所有权限
user_permissions contains permission if {
    some permission in data.roles[input.user.role].permissions
}
```

**技巧**：使用`contains`和`in`操作符进行集合查询。

### 3. 权限检查

```rego
# 允许请求，当用户有相应权限
allow if {
    input.action in user_permissions
}
```

**说明**：使用`in`检查操作是否在用户权限集合中。

---

## 🎓 学习要点

### 1. Set操作

```rego
# user_permissions 是一个集合（Set）
user_permissions contains permission if {
    # ...
}

# 检查元素是否在集合中
allow if {
    input.action in user_permissions
}
```

### 2. 数据驱动策略

通过`data.json`配置角色权限，无需修改策略代码：

```json
{
  "roles": {
    "admin": {
      "permissions": ["read", "write", "delete", "admin"]
    }
  }
}
```

**优势**：策略逻辑与权限配置分离，便于维护。

### 3. 单元测试覆盖

为每个角色和操作组合编写测试：

```rego
test_editor_cannot_delete if {
    not allow with input as {
        "user": {"role": "editor"},
        "action": "delete"
    } with data.roles as test_roles
}
```

**最佳实践**：测试正向场景（应允许）和负向场景（应拒绝）。

---

## 🔧 扩展练习

### 练习1：添加新角色

添加`superadmin`角色，拥有所有权限 + `audit`权限。

**提示**：修改`data.json`，添加测试用例。

### 练习2：资源级别权限

扩展策略支持资源级别权限（如：只能操作自己的资源）。

**输入示例**：

```json
{
  "user": {"id": "user123", "role": "editor"},
  "action": "write",
  "resource": {"id": "doc456", "owner": "user123"}
}
```

**提示**：添加规则检查`input.resource.owner == input.user.id`。

### 练习3：时间限制

添加权限时间窗口（如：仅工作时间允许write）。

**提示**：使用`time.now_ns()`和`time.parse_rfc3339_ns()`函数。

---

## 📚 相关文档

- [访问控制(RBAC)](../../docs/05-应用场景/05.1-访问控制\(RBAC\).md)
- [策略设计模式](../../docs/08-最佳实践/08.1-策略设计模式.md)
- [Rego语法规范](../../docs/02-语言模型/02.1-Rego语法规范.md)

---

## ❓ 常见问题

**Q: 为什么使用`contains`而不是`:=`？**

A: `contains`定义集合（Set），允许多个规则产生多个值。`:=`是赋值，只能有一个值。

**Q: 如何调试权限不生效？**

A: 使用`opa eval`查看中间结果：

```bash
opa eval -i input_admin.json -d policy.rego -d data.json "data.rbac.user_permissions"
```

**Q: 性能如何？**

A: 简单RBAC查询通常<1ms。对于复杂权限树，参考[性能优化指南](../../docs/08-最佳实践/08.2-性能优化指南.md)。

---

**下一步**: 学习 [示例03：Kubernetes准入控制](../03-kubernetes-admission/README.md)
