# OPA/Rego 快速参考指南

> **速查手册** - 一页纸掌握OPA核心语法和常用模式  
> **更新日期**: 2025年10月21日  
> **建议**: 打印后贴在工位 📌

---

## 📋 目录

- [OPA/Rego 快速参考指南](#oparego-快速参考指南)
  - [📋 目录](#-目录)
  - [基础语法](#基础语法)
    - [Package 声明](#package-声明)
    - [Import 导入](#import-导入)
    - [规则定义](#规则定义)
    - [默认值](#默认值)
  - [数据类型](#数据类型)
    - [类型检查](#类型检查)
  - [运算符](#运算符)
    - [赋值与比较](#赋值与比较)
    - [逻辑运算](#逻辑运算)
    - [集合运算](#集合运算)
    - [算术运算](#算术运算)
  - [常用模式](#常用模式)
    - [1. RBAC 基础](#1-rbac-基础)
    - [2. 权限检查](#2-权限检查)
    - [3. 列表推导](#3-列表推导)
    - [4. 对象推导](#4-对象推导)
    - [5. 集合推导](#5-集合推导)
    - [6. 嵌套数据访问](#6-嵌套数据访问)
  - [内置函数速查](#内置函数速查)
    - [字符串操作](#字符串操作)
    - [数组操作](#数组操作)
    - [对象操作](#对象操作)
    - [集合操作](#集合操作)
    - [聚合函数](#聚合函数)
    - [JSON操作](#json操作)
    - [JWT操作](#jwt操作)
    - [时间操作](#时间操作)
    - [HTTP操作](#http操作)
  - [测试与调试](#测试与调试)
    - [单元测试](#单元测试)
    - [运行测试](#运行测试)
    - [调试技巧](#调试技巧)
    - [命令行工具](#命令行工具)
  - [常见错误](#常见错误)
    - [1. 变量作用域错误](#1-变量作用域错误)
    - [2. 统一失败](#2-统一失败)
    - [3. 集合 vs 数组](#3-集合-vs-数组)
    - [4. Undefined vs False](#4-undefined-vs-false)
    - [5. 字符串拼接](#5-字符串拼接)
  - [性能优化 Tip](#性能优化-tip)
    - [1. 提前退出](#1-提前退出)
    - [2. 避免笛卡尔积](#2-避免笛卡尔积)
    - [3. 使用索引](#3-使用索引)
    - [4. 缓存计算](#4-缓存计算)
  - [常用代码片段](#常用代码片段)
    - [日期范围检查](#日期范围检查)
    - [IP 范围检查](#ip-范围检查)
    - [正则匹配](#正则匹配)
    - [JSON Schema 验证](#json-schema-验证)
  - [快速排错清单](#快速排错清单)
  - [相关文档](#相关文档)

---

## 基础语法

### Package 声明

```rego
package example.authz    # 定义策略包路径
```

### Import 导入

```rego
import future.keywords.if       # 推荐：使用新关键字
import future.keywords.contains
import data.users              # 导入数据
```

### 规则定义

```rego
# 完整规则 (Complete Rule)
allow := true if {
    input.user == "admin"
}

# 部分规则 (Partial Rule) - 生成集合
users contains user if {
    some user in data.users
    user.active == true
}

# 函数规则
is_admin(user) if {
    user.role == "admin"
}
```

### 默认值

```rego
default allow := false           # 默认拒绝
default max_connections := 100   # 默认限制
```

---

## 数据类型

| 类型 | 示例 | 说明 |
|------|------|------|
| **Null** | `null` | 空值 |
| **Boolean** | `true`, `false` | 布尔值 |
| **Number** | `42`, `3.14`, `-10` | 整数/浮点数 |
| **String** | `"hello"`, `"user@example.com"` | 字符串 |
| **Array** | `[1, 2, 3]`, `["a", "b"]` | 数组（有序） |
| **Object** | `{"name": "alice", "age": 30}` | 对象（键值对） |
| **Set** | `{1, 2, 3}`, `{"a", "b"}` | 集合（无序、唯一） |

### 类型检查

```rego
is_string(input.name)            # true if name is string
is_number(input.age)             # true if age is number
is_array(input.tags)             # true if tags is array
is_object(input.user)            # true if user is object
is_set(input.roles)              # true if roles is set
is_null(input.optional)          # true if optional is null
is_boolean(input.active)         # true if active is boolean
```

---

## 运算符

### 赋值与比较

```rego
x := 10                  # 局部赋值（:=）
y = 20                   # 统一（=）

x == y                   # 相等比较
x != y                   # 不等比较
x < y                    # 小于
x > y                    # 大于
x <= y                   # 小于等于
x >= y                   # 大于等于
```

### 逻辑运算

```rego
# AND（逗号或换行）
rule if {
    condition1
    condition2
}

# OR（多个规则体）
rule if {
    condition1
}
rule if {
    condition2
}

# NOT
not_admin if {
    not input.user.role == "admin"
}
```

### 集合运算

```rego
x | y                    # 并集
x & y                    # 交集
x - y                    # 差集

"item" in collection     # 成员检查
```

### 算术运算

```rego
x + y                    # 加
x - y                    # 减
x * y                    # 乘
x / y                    # 除
x % y                    # 取模
```

---

## 常用模式

### 1. RBAC 基础

```rego
package authz

import future.keywords.if

# 允许管理员
allow if {
    input.user.role == "admin"
}

# 允许资源所有者
allow if {
    input.user.id == input.resource.owner
}
```

### 2. 权限检查

```rego
# 检查用户是否有特定权限
has_permission(user, action, resource) if {
    some role in user.roles
    some permission in data.role_permissions[role]
    permission.action == action
    permission.resource == resource
}
```

### 3. 列表推导

```rego
# 过滤：获取所有活跃用户
active_users := [user |
    some user in data.users
    user.active == true
]

# 转换：提取用户ID
user_ids := [user.id | some user in data.users]

# 条件：获取管理员邮箱
admin_emails := [user.email |
    some user in data.users
    user.role == "admin"
]
```

### 4. 对象推导

```rego
# 构建用户索引
users_by_id := {user.id: user |
    some user in data.users
}

# 分组统计
users_by_role := {role: users |
    some user in data.users
    role := user.role
    users := [u | some u in data.users; u.role == role]
}
```

### 5. 集合推导

```rego
# 去重：所有角色
all_roles := {user.role | some user in data.users}

# 交集：用户拥有的且需要的权限
granted := user_permissions & required_permissions
```

### 6. 嵌套数据访问

```rego
# 安全访问（不存在返回undefined）
name := input.user.profile.name

# 带默认值
name := object.get(input.user, ["profile", "name"], "Unknown")

# 迭代嵌套
dept_users := [user |
    some dept in data.departments
    some user in dept.users
]
```

---

## 内置函数速查

### 字符串操作

```rego
concat("/", ["a", "b", "c"])           # "a/b/c"
contains("hello world", "world")       # true
startswith("hello", "he")              # true
endswith("hello", "lo")                # true
lower("HELLO")                         # "hello"
upper("hello")                         # "HELLO"
trim_space("  hello  ")                # "hello"
split("a,b,c", ",")                    # ["a", "b", "c"]
sprintf("User: %s", ["alice"])         # "User: alice"
```

### 数组操作

```rego
count([1, 2, 3])                       # 3
array.slice([1,2,3,4], 1, 3)          # [2, 3]
array.concat([1, 2], [3, 4])          # [1, 2, 3, 4]
```

### 对象操作

```rego
object.get(obj, "key", "default")      # 安全获取
object.remove(obj, ["key1", "key2"])   # 移除键
object.keys(obj)                       # 所有键
object.values(obj)                     # 所有值
```

### 集合操作

```rego
intersection(set1, set2)               # 交集
union(set1, set2)                      # 并集
```

### 聚合函数

```rego
count([1, 2, 3])                       # 3
sum([1, 2, 3])                         # 6
max([1, 5, 3])                         # 5
min([1, 5, 3])                         # 1
```

### JSON操作

```rego
json.marshal(value)                    # 编码
json.unmarshal(string)                 # 解码
json.filter(obj, ["key1", "key2"])    # 过滤键
```

### JWT操作

```rego
io.jwt.decode(token)                   # 解码JWT
io.jwt.verify_hs256(token, secret)    # 验证HS256
io.jwt.verify_rs256(token, cert)      # 验证RS256
```

### 时间操作

```rego
time.now_ns()                          # 当前时间（纳秒）
time.parse_rfc3339_ns(timestamp)       # 解析时间
time.add_date(ns, years, months, days) # 添加日期
```

### HTTP操作

```rego
http.send({
    "method": "GET",
    "url": "https://api.example.com/users"
})
```

---

## 测试与调试

### 单元测试

```rego
package authz_test

import future.keywords.if
import data.authz

# 测试：管理员应该被允许
test_admin_allowed if {
    authz.allow with input as {
        "user": {"role": "admin"}
    }
}

# 测试：普通用户应该被拒绝
test_user_denied if {
    not authz.allow with input as {
        "user": {"role": "user"}
    }
}
```

### 运行测试

```bash
# 运行所有测试
opa test . -v

# 运行特定文件
opa test policy_test.rego -v

# 显示覆盖率
opa test . --coverage
```

### 调试技巧

```rego
# 1. 打印调试
allow if {
    print("User:", input.user)        # 打印到stderr
    input.user.role == "admin"
}

# 2. Trace
trace(sprintf("Checking user: %v", [input.user]))

# 3. REPL调试
# opa run policy.rego
# > data.authz.allow with input as {"user": {"role": "admin"}}
```

### 命令行工具

```bash
# 评估策略
opa eval -d policy.rego -i input.json "data.authz.allow"

# 格式化代码
opa fmt policy.rego

# 检查语法
opa check policy.rego

# 性能分析
opa eval --profile -d policy.rego "data.authz.allow"

# 部分求值
opa build -t wasm policy.rego
```

---

## 常见错误

### 1. 变量作用域错误

```rego
# ❌ 错误
rule if {
    x := input.value
}
result := x    # Error: x undefined

# ✅ 正确
rule := x if {
    x := input.value
}
```

### 2. 统一失败

```rego
# ❌ 错误：尝试统一不同的值
x := 1
x := 2    # Error: cannot unify

# ✅ 正确：使用不同变量或条件
x := 1 if { condition1 }
x := 2 if { condition2 }
```

### 3. 集合 vs 数组

```rego
# ❌ 数组不能自动去重
arr := [1, 2, 2, 3]    # [1, 2, 2, 3]

# ✅ 集合自动去重
s := {1, 2, 2, 3}      # {1, 2, 3}
```

### 4. Undefined vs False

```rego
# Undefined（不存在）
default result := false
result if {
    false                # 规则不匹配，result为false
}

# 注意区分undefined和false
```

### 5. 字符串拼接

```rego
# ❌ 错误：不能直接用+
msg := "Hello " + name    # Error

# ✅ 正确：使用concat或sprintf
msg := concat(" ", ["Hello", name])
msg := sprintf("Hello %s", [name])
```

---

## 性能优化 Tip

### 1. 提前退出

```rego
# ✅ 快速检查在前
allow if {
    input.method == "GET"            # 快
    expensive_permission_check()     # 慢
}
```

### 2. 避免笛卡尔积

```rego
# ❌ O(n²)
conflicts := [[u1, u2] |
    some u1 in users
    some u2 in users
    u1.team == u2.team
]

# ✅ O(n) - 先分组
by_team := {team: users | ... }
```

### 3. 使用索引

```rego
# ❌ 线性搜索
user := [u | some u in data.users; u.id == input.user_id][0]

# ✅ 直接索引（需要预处理数据为对象）
user := data.users[input.user_id]
```

### 4. 缓存计算

```rego
# ✅ 计算一次，多次使用
perm_count := count(input.permissions)
allow if {
    perm_count > 5
    perm_count < 20
}
```

---

## 常用代码片段

### 日期范围检查

```rego
import future.keywords.if

valid_date if {
    now := time.now_ns()
    start := time.parse_rfc3339_ns(input.start_date)
    end := time.parse_rfc3339_ns(input.end_date)
    start <= now
    now <= end
}
```

### IP 范围检查

```rego
import future.keywords.if

ip_allowed if {
    net.cidr_contains("10.0.0.0/8", input.source_ip)
}
```

### 正则匹配

```rego
import future.keywords.if

valid_email if {
    regex.match(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`, input.email)
}
```

### JSON Schema 验证

```rego
import future.keywords.if

valid_input if {
    json.match_schema(
        input,
        {
            "type": "object",
            "properties": {
                "user": {"type": "string"},
                "action": {"type": "string"}
            },
            "required": ["user", "action"]
        }
    )
}
```

---

## 快速排错清单

- [ ] 检查 package 声明是否正确
- [ ] 确认 import 路径是否存在
- [ ] 变量名拼写是否正确
- [ ] 规则体是否缺少 `if` 关键字（建议使用）
- [ ] 集合操作是否用在数组上（反之亦然）
- [ ] 是否正确处理 undefined
- [ ] 递归规则是否有终止条件
- [ ] 测试数据结构是否匹配策略期望

---

## 相关文档

- 📖 [完整语法规范](./02-语言模型/02.1-Rego语法规范.md)
- 🔧 [内置函数库](./02-语言模型/02.3-内置函数库.md)
- 💼 [RBAC实战](./05-应用场景/05.1-访问控制(RBAC).md)
- ⭐ [设计模式](./08-最佳实践/08.1-策略设计模式.md)
- ⚡ [性能优化](./08-最佳实践/08.2-性能优化指南.md)

---

**提示**: 这是一份速查手册，详细说明请参考对应的完整文档 📚

**更新**: 2025年10月21日 | **版本**: v2.0
