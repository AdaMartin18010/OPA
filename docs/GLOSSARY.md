# OPA/Rego 术语表（Glossary）

> **技术术语速查** - 快速理解OPA/Rego核心概念  
> **更新日期**: 2025年10月21日  
> **按字母排序** | **中英对照**

---

## 目录

- [A](#a) | [B](#b) | [C](#c) | [D](#d) | [E](#e) | [F](#f) | [G](#g) | [H](#h) | [I](#i) | [J](#j) | [K](#k) | [L](#l) | [M](#m)
- [N](#n) | [O](#o) | [P](#p) | [Q](#q) | [R](#r) | [S](#s) | [T](#t) | [U](#u) | [V](#v) | [W](#w) | [X](#x) | [Y](#y) | [Z](#z)

---

## A

### ABAC (Attribute-Based Access Control)
**基于属性的访问控制**

一种访问控制模型，根据用户、资源和环境的属性来做决策。

```rego
# 示例：年龄大于18岁且在工作时间内可以访问
allow if {
    input.user.age >= 18
    time.hour >= 9
    time.hour < 18
}
```

**相关**：[RBAC](#rbac-role-based-access-control)、[Policy](#policy)

---

### Admission Control
**准入控制**

Kubernetes中的机制，在对象持久化到etcd之前拦截API请求并执行策略检查。

**相关**：[Webhook](#webhook)、[Gatekeeper](#gatekeeper)

---

### AST (Abstract Syntax Tree)
**抽象语法树**

Rego代码解析后的树状结构表示，用于编译和求值。

```text
规则: allow if { input.user == "admin" }

AST:
  Rule
  ├── Head: allow
  └── Body
      └── Expr: input.user == "admin"
```

**文档**：[AST与IR](./03-实现架构/03.2-AST与IR.md)

---

### Assignment
**赋值**

使用 `:=` 运算符给局部变量赋值。

```rego
x := 10          # 赋值
y := input.value # 赋值
```

**对比**：[Unification](#unification)

---

## B

### Backtracking
**回溯**

Rego求值器在规则匹配失败时，回退到前一个选择点重新尝试的机制。

```rego
# 示例：回溯查找
user if {
    some u in data.users    # 尝试每个用户
    u.name == input.name    # 如果不匹配，回溯
}
```

**文档**：[Top-Down求值器](./03-实现架构/03.4-Top-Down求值器.md)

---

### Body
**规则体**

规则的条件部分，包含一个或多个表达式。

```rego
allow if {      # ← Head（规则头）
    expr1       # ← Body（规则体）
    expr2       # ← Body（规则体）
}
```

---

### Bundle
**策略包**

OPA的分发单元，包含策略文件、数据和签名的tar.gz压缩包。

**结构**：
```text
bundle.tar.gz
├── .manifest         # 元数据
├── policy.rego       # 策略文件
├── data.json         # 数据文件
└── .signatures.json  # 签名（可选）
```

**文档**：[Bundle格式规范](./01-技术规范/01.2-Bundle格式规范.md)

---

### Built-in Function
**内置函数**

OPA预定义的150+个函数，用于字符串、数组、对象、时间等操作。

```rego
count([1, 2, 3])                # 3
concat("/", ["a", "b"])         # "a/b"
time.now_ns()                   # 当前时间
```

**文档**：[内置函数库](./02-语言模型/02.3-内置函数库.md)

---

## C

### Comprehension
**推导式**

生成新集合的语法，包括数组推导、对象推导和集合推导。

```rego
# 数组推导
admins := [u | some u in data.users; u.role == "admin"]

# 对象推导
by_id := {u.id: u | some u in data.users}

# 集合推导
roles := {u.role | some u in data.users}
```

---

### Complete Rule
**完整规则**

产生单一值的规则。

```rego
allow := true if {     # 完整规则：allow = true
    input.user == "admin"
}

max_count := 100       # 完整规则：max_count = 100
```

**对比**：[Partial Rule](#partial-rule)

---

### Constraint
**约束**

Gatekeeper中定义的策略实例，指定要检查的资源和参数。

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-team-label
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    labels: ["team"]
```

**相关**：[ConstraintTemplate](#constrainttemplate)

---

### ConstraintTemplate
**约束模板**

Gatekeeper中定义的可重用策略模板，包含Rego代码和参数定义。

**文档**：[Gatekeeper详解](./04-生态系统/04.2-Gatekeeper详解.md)

---

## D

### Data
**数据**

预加载到OPA中的静态数据，通过 `data` 变量访问。

```rego
allow if {
    some role in input.user.roles
    data.role_permissions[role].can_read  # 访问预加载数据
}
```

**对比**：[Input](#input)

---

### Datalog
**数据日志**

一种声明式查询语言，Rego的理论基础。

**文档**：[Datalog理论基础](./06-形式化证明/06.1-Datalog理论基础.md)

---

### Decision Log
**决策日志**

OPA记录的每次策略评估的详细信息，包括输入、输出和性能数据。

```json
{
  "decision_id": "abc123",
  "input": {"user": "alice"},
  "result": true,
  "timestamp": "2025-10-21T10:00:00Z",
  "metrics": {
    "timer_rego_query_eval_ns": 125000
  }
}
```

---

### Default
**默认值**

规则未匹配时的默认返回值。

```rego
default allow := false    # 默认拒绝
default max_age := 100    # 默认最大年龄
```

---

## E

### Evaluation
**求值**

执行Rego策略并产生结果的过程。

**相关**：[Top-Down Evaluation](#top-down-evaluation)

---

### Expression
**表达式**

Rego中的基本计算单元。

```rego
# 各种表达式
input.user == "admin"       # 比较表达式
x := 10                     # 赋值表达式
some user in data.users     # 迭代表达式
```

---

## F

### Function
**函数**

可重用的规则，接受参数并返回值。

```rego
# 定义函数
is_admin(user) if {
    user.role == "admin"
}

# 调用函数
allow if {
    is_admin(input.user)
}
```

---

## G

### Gatekeeper
**守门员**

Kubernetes的策略控制器，使用OPA实现准入控制。

**文档**：[Gatekeeper详解](./04-生态系统/04.2-Gatekeeper详解.md)

---

## H

### Head
**规则头**

规则的名称和可选参数部分。

```rego
allow if { ... }           # Head: allow
users[user.id] := user if { ... }  # Head: users[user.id]
```

---

## I

### Input
**输入**

查询时传入OPA的动态数据，通过 `input` 变量访问。

```json
{
  "user": "alice",
  "action": "read",
  "resource": "/api/data"
}
```

```rego
allow if {
    input.user == "alice"
    input.action == "read"
}
```

**对比**：[Data](#data)

---

### Indexing
**索引**

OPA自动创建的数据结构，用于加速查询。

**文档**：[索引与优化](./03-实现架构/03.5-索引与优化.md)

---

### IR (Intermediate Representation)
**中间表示**

AST转换后的优化表示，用于代码生成。

**文档**：[AST与IR](./03-实现架构/03.2-AST与IR.md)

---

## J

### JWT (JSON Web Token)
**JSON Web令牌**

常用的认证令牌格式，OPA提供内置函数解码和验证。

```rego
[header, payload, sig] := io.jwt.decode(input.token)
allow if {
    payload.role == "admin"
}
```

---

## K

### Kubernetes Admission Webhook
**Kubernetes准入Webhook**

Kubernetes调用外部服务验证和修改资源的机制。

**文档**：[Kubernetes集成](./04-生态系统/04.1-Kubernetes集成.md)

---

## L

### Literal
**字面量**

直接在代码中写的常量值。

```rego
x := 10               # 数字字面量
name := "alice"       # 字符串字面量
allowed := true       # 布尔字面量
```

---

## M

### Module
**模块**

一个Rego文件，包含package声明和规则定义。

```rego
package example.authz    # Package声明

import future.keywords.if

allow if {              # 规则定义
    input.user == "admin"
}
```

---

## N

### Namespace
**命名空间**

Package定义的层次化名称空间。

```rego
package example.authz.admin    # 命名空间

# 访问：data.example.authz.admin.allow
```

---

## O

### OPA (Open Policy Agent)
**开放策略代理**

CNCF毕业的通用策略引擎，使用Rego语言编写策略。

**官网**：https://www.openpolicyagent.org/

---

### Operator
**运算符**

Rego中的操作符号。

| 运算符 | 类型 | 示例 |
|--------|------|------|
| `:=` | 赋值 | `x := 10` |
| `=` | 统一 | `x = input.value` |
| `==` | 相等 | `x == y` |
| `!=` | 不等 | `x != y` |
| `<`, `>`, `<=`, `>=` | 比较 | `x > 10` |
| `+`, `-`, `*`, `/`, `%` | 算术 | `x + y` |
| `\|`, `&`, `-` | 集合 | `set1 \| set2` |

---

## P

### Package
**包**

模块的命名空间声明。

```rego
package example.authz    # Package声明
```

---

### Partial Evaluation
**部分求值**

预先计算策略的部分内容，减少运行时开销。

**文档**：[部分求值技术](./03-实现架构/03.6-部分求值技术.md)

---

### Partial Rule
**部分规则**

生成集合或对象的规则。

```rego
# 部分规则：生成集合
admins contains user.name if {
    some user in data.users
    user.role == "admin"
}

# 部分规则：生成对象
users[user.id] := user if {
    some user in data.users
}
```

**对比**：[Complete Rule](#complete-rule)

---

### Policy
**策略**

用Rego编写的决策规则。

```rego
package authz

allow if {
    input.user.role == "admin"
}
```

---

## Q

### Query
**查询**

对OPA策略的请求。

```bash
# CLI查询
opa eval -d policy.rego "data.authz.allow"

# HTTP查询
POST /v1/data/authz/allow
{
  "input": {"user": "alice"}
}
```

---

## R

### RBAC (Role-Based Access Control)
**基于角色的访问控制**

根据用户角色授予权限的访问控制模型。

```rego
allow if {
    some role in input.user.roles
    data.role_permissions[role].can_read
}
```

**文档**：[访问控制(RBAC)](./05-应用场景/05.1-访问控制(RBAC).md)

---

### Rego
**Rego语言**

OPA的策略语言，基于Datalog，声明式。

**文档**：[Rego语法规范](./02-语言模型/02.1-Rego语法规范.md)

---

### REPL (Read-Eval-Print Loop)
**交互式解释器**

OPA的交互式命令行环境。

```bash
opa run policy.rego
> data.authz.allow with input as {"user": "alice"}
```

---

### Rule
**规则**

Rego中的基本决策单元。

```rego
# 规则语法
<head> if {
    <body>
}
```

---

## S

### Set
**集合**

无序、唯一元素的数据结构。

```rego
roles := {"admin", "user", "guest"}
roles := {"admin", "user", "admin"}  # → {"admin", "user"}
```

**对比**：Array（数组）是有序、可重复的

---

### Sidecar
**边车**

与应用容器一起运行的OPA容器，提供低延迟决策。

```yaml
# Kubernetes Sidecar
containers:
  - name: app
    image: my-app
  - name: opa
    image: openpolicyagent/opa:latest
```

---

### SLD-Resolution
**SLD归结**

Rego求值器使用的推理算法。

**文档**：[Top-Down求值器](./03-实现架构/03.4-Top-Down求值器.md)

---

## T

### Term
**项**

Rego中的基本数据单元（值、变量、引用）。

```rego
42                      # 数字项
"hello"                 # 字符串项
input.user             # 引用项
x                      # 变量项
```

---

### Top-Down Evaluation
**自顶向下求值**

OPA使用的求值策略，从查询开始向下展开规则。

**文档**：[Top-Down求值器](./03-实现架构/03.4-Top-Down求值器.md)

---

### Type System
**类型系统**

Rego的动态、强类型系统。

**类型**：Null、Boolean、Number、String、Array、Object、Set

**文档**：[类型系统](./02-语言模型/02.2-类型系统.md)

---

## U

### Unification
**统一**

使用 `=` 运算符，尝试使两个值相等或绑定变量。

```rego
x = 10              # 如果x未绑定，绑定为10；否则检查是否等于10
input.user = "admin"  # 检查是否相等
```

**对比**：[Assignment](#assignment)

---

### Undefined
**未定义**

规则不匹配时的结果状态。

```rego
allow if {
    input.user == "admin"  # 如果不匹配，allow为undefined
}
```

**对比**：False（显式的布尔假值）

---

## V

### Variable
**变量**

存储值的标识符。

```rego
x := 10                # 局部变量
user := input.user     # 局部变量
```

---

### Violation
**违规**

Gatekeeper中表示策略违反的消息。

```rego
violation[{"msg": msg}] if {
    not input.review.object.metadata.labels.team
    msg := "Pod must have 'team' label"
}
```

---

## W

### WASM (WebAssembly)
**Web汇编**

OPA可以将Rego编译为WASM，在浏览器或边缘环境运行。

```bash
opa build -t wasm policy.rego
```

**文档**：[WASM编译规范](./01-技术规范/01.3-WASM编译规范.md)

---

### Webhook
**Web钩子**

HTTP回调，Kubernetes用来调用OPA进行准入控制。

**相关**：[Admission Control](#admission-control)

---

### With
**替换**

测试时临时替换input或data的值。

```rego
test_admin_allowed if {
    allow with input as {"user": {"role": "admin"}}
}
```

---

## X

### (暂无常用术语)

---

## Y

### (暂无常用术语)

---

## Z

### Zero Trust
**零信任**

安全模型，不信任网络内外的任何请求，全部验证。

OPA常用于实现零信任架构的策略引擎。

---

## 📚 相关资源

### 核心文档
- 📖 [Rego语法规范](./02-语言模型/02.1-Rego语法规范.md)
- 🔧 [内置函数库](./02-语言模型/02.3-内置函数库.md)
- 📚 [完整文档索引](./00-总览与索引.md)

### 快速工具
- ⚡ [快速参考](./QUICK_REFERENCE.md)
- ❓ [常见问题](./FAQ.md)
- 🎯 [学习路线图](./LEARNING_PATH.md)

---

## 🔍 查找技巧

### 按类别
- **语言特性**：[Rule](#rule)、[Function](#function)、[Comprehension](#comprehension)
- **运算符**：[Assignment](#assignment)、[Unification](#unification)、[Operator](#operator)
- **数据结构**：[Set](#set)、[Array](#array)、[Object](#object)
- **架构组件**：[AST](#ast-abstract-syntax-tree)、[IR](#ir-intermediate-representation)、[Bundle](#bundle)
- **部署模式**：[Sidecar](#sidecar)、[Webhook](#webhook)、[WASM](#wasm-webassembly)
- **访问控制**：[RBAC](#rbac-role-based-access-control)、[ABAC](#abac-attribute-based-access-control)

### 按首字母
使用顶部的字母导航快速定位术语。

---

**更新**: 2025年10月21日 | **版本**: v2.1  
**贡献**: 欢迎补充术语！请提交 [Pull Request](../CONTRIBUTING.md)

