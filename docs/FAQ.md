# OPA/Rego 常见问题解答（FAQ）

> **Frequently Asked Questions**  
> **更新日期**: 2025年10月21日  
> **涵盖**: 概念、语法、部署、调试、性能

---

## 📋 目录

- [基础概念](#基础概念)
- [语法与语义](#语法与语义)
- [数据与输入](#数据与输入)
- [部署与集成](#部署与集成)
- [性能与优化](#性能与优化)
- [调试与测试](#调试与测试)
- [安全性](#安全性)
- [常见错误](#常见错误)

---

## 基础概念

### Q1: OPA 是什么？适用于哪些场景？

**A**: OPA (Open Policy Agent) 是一个**通用策略引擎**，使用声明式语言 Rego 编写策略。

**适用场景**：
- ✅ API 授权（微服务、网关）
- ✅ Kubernetes 准入控制（Gatekeeper）
- ✅ CI/CD 合规性检查（Terraform、Dockerfile）
- ✅ 数据过滤（多租户、GDPR）
- ✅ 基础设施即代码（IaC）策略

**不适用场景**：
- ❌ 复杂的状态机逻辑
- ❌ 需要副作用的操作（数据库写入）
- ❌ 实时流处理

---

### Q2: OPA vs 其他授权方案（如 Casbin、Spring Security）？

| 特性 | OPA | Casbin | Spring Security |
|------|-----|--------|-----------------|
| **语言** | Rego（声明式） | PERM模型 | Java代码 |
| **通用性** | 通用（任意应用） | 通用 | Spring生态 |
| **部署** | 独立/Sidecar/库 | 库 | 库 |
| **策略即代码** | ✅ | ✅ | ⚠️ |
| **云原生** | ✅（CNCF毕业） | ⚠️ | ❌ |
| **学习曲线** | 中等 | 低 | 低（Java开发者） |

**选择建议**：
- **OPA**: 云原生、多语言、复杂策略
- **Casbin**: 简单RBAC/ABAC，快速集成
- **Spring Security**: Java单体应用

---

### Q3: Rego 语言难学吗？

**A**: Rego 是声明式语言，有一定学习曲线，但不难。

**学习时间**：
- **基础语法**: 2-4小时
- **编写简单策略**: 1-2天
- **掌握高级特性**: 1-2周

**难点**：
- 统一（unification）概念
- 声明式思维（vs 命令式）
- 部分求值（partial evaluation）

**建议**：
1. 从简单的 if-then 规则开始
2. 在 [OPA Playground](https://play.openpolicyagent.org/) 练习
3. 阅读官方示例和本文档的 [RBAC案例](./05-应用场景/05.1-访问控制(RBAC).md)

---

## 语法与语义

### Q4: `:=` 和 `=` 有什么区别？

**A**: 这是 Rego 中最容易混淆的概念。

| 运算符 | 名称 | 用途 | 示例 |
|--------|------|------|------|
| `:=` | **赋值** (Assignment) | 创建局部变量 | `x := 10` |
| `=` | **统一** (Unification) | 断言相等或绑定变量 | `x = input.value` |

```rego
# := 赋值
x := 10          # x 被赋值为 10
x := 20          # Error: x 已定义

# = 统一
x = 10           # 如果 x 未绑定，绑定为 10；否则检查是否等于 10
x = 10           # OK（第二次统一成功）
x = 20           # Fail（统一失败）
```

**最佳实践**：
- 使用 `:=` 创建局部变量
- 使用 `=` 进行模式匹配和条件检查

---

### Q5: 如何理解 "undefined" vs "false"？

**A**: Rego 中规则可以产生三种结果：

| 结果 | 含义 | 示例 |
|------|------|------|
| **true** | 规则匹配成功 | `allow if { input.user == "admin" }` |
| **false** | 显式设置或默认值 | `default allow := false` |
| **undefined** | 规则不匹配，无结果 | （规则体条件不满足） |

```rego
package example

# 默认值：false
default allow := false

# 规则1：匹配则为 true
allow if {
    input.user == "admin"
}

# 查询结果：
# - user="admin" → true
# - user="bob"   → false（默认值）
# - 无 user      → false（默认值）
```

**重要**：在决策中，通常将 `undefined` 视为 `false`（通过 default）。

---

### Q6: 如何遍历数组和对象？

**A**: 使用 `some ... in ...` 语法。

```rego
import future.keywords.if
import future.keywords.in

# 遍历数组
arr := [1, 2, 3]
sum := s if {
    s := sum([x | some x in arr])
}

# 遍历对象（键值对）
obj := {"a": 1, "b": 2}
keys := [k | some k, v in obj]        # ["a", "b"]
values := [v | some k, v in obj]      # [1, 2]

# 嵌套遍历
users := [
    {"name": "alice", "age": 30},
    {"name": "bob", "age": 25}
]
names := [u.name | some u in users]   # ["alice", "bob"]
```

---

### Q7: 集合 vs 数组，何时用哪个？

**A**: 

| 类型 | 特点 | 适用场景 | 语法 |
|------|------|---------|------|
| **Array** | 有序、可重复 | 列表、序列 | `[1, 2, 2]` |
| **Set** | 无序、唯一 | 去重、集合运算 | `{1, 2, 2}` → `{1, 2}` |

```rego
# Array：保留顺序和重复
roles_arr := ["admin", "user", "admin"]   # ["admin", "user", "admin"]

# Set：自动去重
roles_set := {"admin", "user", "admin"}   # {"admin", "user"}

# 集合运算（只能用于 Set）
admin_roles := {"admin", "superadmin"}
user_roles := {"user", "admin"}
common := admin_roles & user_roles        # {"admin"}
```

**建议**：
- 需要顺序或重复：用 **Array**
- 需要去重或集合运算：用 **Set**

---

## 数据与输入

### Q8: `data` 和 `input` 的区别？

**A**: 

| 变量 | 来源 | 可变性 | 用途 |
|------|------|--------|------|
| **`input`** | 查询时传入 | 每次查询不同 | 请求上下文（用户、资源） |
| **`data`** | 预加载（Bundle/API） | 相对静态 | 策略数据（角色、权限） |

```rego
package authz

import future.keywords.if

# input: 请求时传入
allow if {
    input.user.role == "admin"         # 每次请求的用户
}

# data: 预加载的数据
allow if {
    some role in input.user.roles
    data.role_permissions[role].can_read  # 预加载的权限配置
}
```

**查询示例**：
```bash
opa eval -d data.json -i input.json "data.authz.allow"
#        ↑ 预加载     ↑ 请求输入
```

---

### Q9: 如何更新 `data`？

**A**: OPA 支持三种方式更新数据：

#### 1. **Bundle 推送**（推荐 - 生产）
```bash
# 构建 Bundle
opa build -b policy/ data/

# OPA 配置拉取
{
  "bundles": {
    "authz": {
      "resource": "https://bundle-server.com/bundle.tar.gz"
    }
  }
}
```

#### 2. **API 更新**（临时 - 开发）
```bash
# PUT 更新数据
curl -X PUT http://localhost:8181/v1/data/users \
  -d '{"alice": {"role": "admin"}}'
```

#### 3. **文件加载**（启动时）
```bash
opa run --server --set-file data.json
```

**生产建议**：使用 **Bundle + 版本控制 + 签名验证**。

---

### Q10: 数据太大怎么办？

**A**: 几种优化策略：

1. **数据分片**：按模块拆分（users、roles、permissions）
2. **按需加载**：只加载当前需要的数据子集
3. **数据预处理**：
   - 数组转对象（O(1) 查找）
   - 预计算索引
4. **部分求值**：提前计算固定部分
5. **外部数据源**：使用 `http.send()` 按需查询

示例：
```rego
# ❌ 慢：线性搜索 10MB 数据
user := [u | some u in data.users; u.id == input.user_id][0]

# ✅ 快：O(1) 索引查找（需预处理数据为对象）
user := data.users_by_id[input.user_id]
```

---

## 部署与集成

### Q11: OPA 应该部署为 Sidecar、DaemonSet 还是中心化服务？

**A**: 

| 模式 | 优势 | 劣势 | 适用场景 |
|------|------|------|---------|
| **Sidecar** | 低延迟、隔离性好 | 资源占用高 | 微服务（K8s） |
| **DaemonSet** | 节点共享、资源节省 | 跨Pod影响 | 节点级策略 |
| **中心化** | 统一管理、易更新 | 网络延迟、单点 | 少量应用 |
| **进程内库** | 零延迟、无网络 | 更新需重启 | 关键路径 |

**推荐**：
- **Kubernetes 微服务**: Sidecar（延迟 < 1ms）
- **API 网关**: 中心化（Envoy ext_authz）
- **边缘计算**: WASM（体积小、隔离）

---

### Q12: 如何集成到现有应用？

**A**: 三种主流方式：

#### 1. **HTTP API**（最通用）
```javascript
// JavaScript 示例
const response = await fetch('http://opa:8181/v1/data/authz/allow', {
  method: 'POST',
  body: JSON.stringify({ input: { user: 'alice', action: 'read' } })
});
const decision = await response.json();
if (decision.result) {
  // 允许
}
```

#### 2. **SDK/库**（性能优先）
```go
// Go 示例
import "github.com/open-policy-agent/opa/rego"

query, _ := rego.New(
    rego.Query("data.authz.allow"),
    rego.Load([]string{"policy.rego"}, nil),
).PrepareForEval(ctx)

rs, _ := query.Eval(ctx, rego.EvalInput(input))
```

#### 3. **WASM**（边缘/浏览器）
```javascript
// 浏览器示例
const { loadPolicy } = require("@open-policy-agent/opa-wasm");
const policy = await loadPolicy(policyWasm);
const result = policy.evaluate(input);
```

---

### Q13: 如何实现策略版本管理？

**A**: 

```yaml
# Bundle Manifest（.manifest）
revision: v1.2.3
roots:
  - authz
  - data

# OPA 配置自动拉取
bundles:
  authz:
    service: bundle-server
    resource: bundle.tar.gz
    polling:
      min_delay_seconds: 60
      max_delay_seconds: 120
```

**最佳实践**：
1. **Git 管理策略代码**（版本控制）
2. **CI/CD 自动测试**（OPA test）
3. **Bundle 签名**（防篡改）
4. **灰度发布**（分阶段推送）

---

## 性能与优化

### Q14: OPA 性能如何？能处理多少 QPS？

**A**: 

**基准性能**：
- **简单规则**（布尔判断）: **> 100 万次/秒**（单核）
- **RBAC 查询**（中等复杂度）: **10k-50k 次/秒**
- **复杂规则**（嵌套循环）: **1k-10k 次/秒**

**影响因素**：
1. 策略复杂度（循环、递归）
2. 数据大小（`data` 越大越慢）
3. 部署模式（Sidecar > 中心化）

**优化建议**：
- 提前退出（快速检查在前）
- 避免笛卡尔积
- 数据索引化
- 使用部分求值

参考：[性能优化指南](./08-最佳实践/08.2-性能优化指南.md)

---

### Q15: 如何监控 OPA 性能？

**A**: 

```yaml
# 启用指标
opa run --server \
  --set decision_logs.console=true \
  --set status.console=true
```

**关键指标**（Prometheus）：

| 指标 | 说明 | 目标值 |
|------|------|--------|
| `opa_http_request_duration_seconds` | 请求延迟 | P99 < 10ms |
| `opa_http_request_total` | 吞吐量 | > 10k req/s |
| `go_memstats_alloc_bytes` | 内存占用 | < 500MB |

```promql
# P99 延迟
histogram_quantile(0.99, 
  rate(opa_http_request_duration_seconds_bucket[5m]))

# 错误率
rate(opa_http_request_total{code=~"5.."}[5m]) /
rate(opa_http_request_total[5m])
```

---

## 调试与测试

### Q16: 如何调试 Rego 策略？

**A**: 

#### 1. **REPL 交互**
```bash
opa run policy.rego
> data.authz.allow with input as {"user": "alice"}
```

#### 2. **print() 调试**
```rego
allow if {
    print("User:", input.user)
    input.user.role == "admin"
}
```

#### 3. **Trace 模式**
```bash
opa eval --explain=full -d policy.rego "data.authz.allow"
```

#### 4. **Playground**
在线调试：https://play.openpolicyagent.org/

---

### Q17: 如何编写单元测试？

**A**: 

```rego
# policy_test.rego
package authz_test

import data.authz
import future.keywords.if

test_admin_allowed if {
    authz.allow with input as {
        "user": {"role": "admin"}
    }
}

test_user_denied if {
    not authz.allow with input as {
        "user": {"role": "user"}
    }
}

test_owner_allowed if {
    authz.allow with input as {
        "user": {"id": "u1"},
        "resource": {"owner": "u1"}
    }
}
```

**运行测试**：
```bash
opa test . -v                # 所有测试
opa test . --coverage        # 覆盖率
opa test . --benchmark       # 性能测试
```

---

## 安全性

### Q18: OPA 如何保证策略的安全性？

**A**: 

1. **Bundle 签名**：
```bash
# 签名
opa build -b policy/ data/ --signing-key private_key.pem

# 验证
opa run --verification-key public_key.pem --bundle bundle.tar.gz
```

2. **TLS/mTLS**：
```yaml
# OPA 配置
services:
  - name: bundle-server
    url: https://example.com
    credentials:
      bearer:
        token: "secret"
```

3. **RBAC（OPA 自身）**：
```rego
# 限制 API 访问
package system.authz

allow if {
    input.identity == "admin"
}
```

---

### Q19: 策略本身会有安全漏洞吗？

**A**: 是的，常见漏洞：

| 漏洞类型 | 示例 | 修复 |
|---------|------|------|
| **默认允许** | 无 `default allow := false` | 显式拒绝 |
| **条件不完整** | 只检查角色，不检查资源 | 完整条件 |
| **注入攻击** | 直接拼接字符串 | 参数化查询 |
| **DoS** | 无限递归、大循环 | 限制复杂度 |

**最佳实践**：
- ✅ 默认拒绝（Deny by Default）
- ✅ 最小权限原则
- ✅ 策略代码审查
- ✅ 自动化测试

---

## 常见错误

### Q20: "var x is unsafe" 错误是什么？

**A**: Rego 要求所有变量必须被"安全地绑定"（从输入或数据推导）。

```rego
# ❌ 错误：x 未绑定
allow if {
    x > 10    # x 从哪来？
}

# ✅ 正确：x 从 input 绑定
allow if {
    x := input.count
    x > 10
}

# ✅ 正确：x 从迭代绑定
allow if {
    some x in input.values
    x > 10
}
```

---

### Q21: "rego_type_error: undefined function" 错误？

**A**: 常见原因：

1. **拼写错误**
```rego
# ❌ 错误
concate("a", "b")    # 拼写错误

# ✅ 正确
concat("", ["a", "b"])
```

2. **函数签名不匹配**
```rego
# ❌ 错误
count([1, 2], [3, 4])    # count 只接受1个参数

# ✅ 正确
count([1, 2])
```

3. **未导入内置函数**
```rego
import future.keywords.if
import future.keywords.in   # 某些版本需要
```

---

### Q22: 策略太慢怎么办？

**A**: 诊断步骤：

1. **性能分析**
```bash
opa eval --profile -d policy.rego "data.authz.allow"
```

2. **查看瓶颈**
   - 嵌套循环？→ 优化算法
   - 数据太大？→ 索引化
   - 外部调用？→ 缓存

3. **应用优化**
   - 参考 [性能优化指南](./08-最佳实践/08.2-性能优化指南.md)
   - 使用部分求值
   - 编译为 WASM

---

## 获取更多帮助

### 📚 文档资源

- [OPA 官方文档](https://www.openpolicyagent.org/docs/)
- [本项目文档索引](./00-总览与索引.md)
- [快速参考](./QUICK_REFERENCE.md)

### 💬 社区支持

- [Slack #opa](https://slack.openpolicyagent.org/)
- [GitHub Discussions](https://github.com/open-policy-agent/opa/discussions)
- [Stack Overflow [opa]](https://stackoverflow.com/questions/tagged/open-policy-agent)

### 🐛 报告问题

- [GitHub Issues](https://github.com/open-policy-agent/opa/issues)

---

**没有找到你的问题？**  
欢迎在 [GitHub Issues](https://github.com/your-repo/opa/issues) 提出！

**更新**: 2025年10月21日 | **版本**: v2.0

