# 示例1：Hello World - OPA基础入门

> **适用版本**: OPA v0.55+ | Rego v1.0  
> **测试版本**: OPA v0.68.0  
> **最后验证**: 2025-10-21  
> **测试状态**: ✅ 已通过所有测试

---

## 📋 示例说明

这是一个最简单的OPA策略示例，演示：

- ✅ 基础策略语法（package, import, rules）
- ✅ 默认值设置（default）
- ✅ 条件判断（if）
- ✅ 输入数据访问（input）
- ✅ 字符串格式化（sprintf）
- ✅ 单元测试编写

---

## 🚀 快速运行

### 1. 评估策略

```bash
# 查询allow规则
opa eval -d policy.rego -i input.json "data.example.hello.allow"

# 输出: true (因为用户是admin)
```

### 2. 查询欢迎消息

```bash
opa eval -d policy.rego -i input.json "data.example.hello.greeting"

# 输出: "Hello, Alice! Welcome to OPA."
```

### 3. 运行测试

```bash
opa test . -v

# 输出:
# policy_test.rego:
# data.example.hello.test_admin_allowed: PASS (0.5ms)
# data.example.hello.test_owner_allowed: PASS (0.3ms)
# data.example.hello.test_deny_access: PASS (0.4ms)
# data.example.hello.test_greeting_admin: PASS (0.3ms)
# data.example.hello.test_greeting_denied: PASS (0.3ms)
# --------------------------------------------------------------------------------
# PASS: 5/5
```

---

## 🧪 尝试不同场景

### 场景1：普通用户访问自己的资源

创建 `input-owner.json`:

```json
{
  "user": {
    "id": "2",
    "name": "Bob",
    "role": "user"
  },
  "resource": {
    "id": "resource-123",
    "owner": "2"
  }
}
```

```bash
opa eval -d policy.rego -i input-owner.json "data.example.hello.allow"
# 输出: true (资源所有者可以访问)
```

### 场景2：普通用户访问他人资源

创建 `input-denied.json`:

```json
{
  "user": {
    "id": "3",
    "name": "Charlie",
    "role": "user"
  },
  "resource": {
    "id": "resource-123",
    "owner": "2"
  }
}
```

```bash
opa eval -d policy.rego -i input-denied.json "data.example.hello.allow"
# 输出: false (非所有者、非admin)

opa eval -d policy.rego -i input-denied.json "data.example.hello.greeting"
# 输出: "Access Denied"
```

---

## 💻 在OPA Playground中运行

> 💻 **在线试一试**:  
> 复制 `policy.rego` 和 `input.json` 的内容到 [OPA Playground](https://play.openpolicyagent.org/)  
> 在Query栏输入: `data.example.hello.allow`

---

## 📚 核心概念解释

### 1. Package声明

```rego
package example.hello
```

- 定义策略的命名空间
- 查询时使用: `data.example.hello.规则名`

### 2. Import语句

```rego
import rego.v1
```

- 导入Rego v1.0语法（推荐）
- 启用新的关键字和语法特性

### 3. 默认值

```rego
default allow := false
```

- 设置规则的默认值
- 如果没有规则匹配，返回false

### 4. 条件规则

```rego
allow if {
    input.user.role == "admin"
}
```

- `if`关键字引入条件
- 花括号内是条件表达式
- 所有条件为真时，规则为真

### 5. 字符串格式化

```rego
msg := sprintf("Hello, %s!", [input.user.name])
```

- `sprintf`用于字符串插值
- 格式化参数放在数组中

---

## 🎯 学习要点

1. **策略即代码**: Rego策略可以版本控制、测试、复用
2. **声明式语法**: 描述"什么"而非"如何"
3. **测试驱动**: 每个策略都应有完整的测试覆盖
4. **输入驱动**: 策略从`input`对象获取上下文信息

---

## 📖 相关文档

- [Rego语法规范](../../docs/02-语言模型/02.1-Rego语法规范.md)
- [类型系统](../../docs/02-语言模型/02.2-类型系统.md)
- [快速参考指南](../../docs/QUICK_REFERENCE.md)

---

## ⚠️ 生产环境注意

> ⚠️ **生产环境部署前请注意**:
> 
> - ✅ 完整的测试覆盖（单元测试 + 集成测试）
> - ✅ 性能基准测试（策略评估延迟）
> - ✅ 错误处理和降级策略
> - ✅ 监控和告警配置
> - ✅ 审计日志记录

---

**下一步**: 查看 [02-basic-rbac](../02-basic-rbac/) 学习角色权限控制 🚀

