# OPA/Rego 代码示例集

> **状态**: ✅ 3个示例已完成  
> **测试**: 🔄 自动化CI测试  
> **版本**: OPA v0.68+

本目录包含可运行的OPA/Rego策略示例，每个示例都包含完整代码、测试和文档。

---

## 📚 示例列表

| 示例 | 难度 | 场景 | 测试 | 学习时间 |
|------|------|------|------|----------|
| [01-hello-world](./01-hello-world/) | ⭐ 入门 | 基础语法 | ✅ 2/2 | 10分钟 |
| [02-basic-rbac](./02-basic-rbac/) | ⭐⭐ 入门 | 角色权限控制 | ✅ 20+个 | 20-30分钟 |
| [03-kubernetes-admission](./03-kubernetes-admission/) | ⭐⭐⭐ 中级 | K8s准入控制 | ✅ 18+个 | 30-45分钟 |

**统计**: 3个示例 | 40+个测试用例 | ~800行代码

---

## 🎓 学习路径

### 入门路径（⭐）

1. **[01-hello-world](./01-hello-world/)** - Rego基础语法
2. **[02-basic-rbac](./02-basic-rbac/)** - RBAC权限模型

### 中级路径（⭐⭐⭐）

1. **[03-kubernetes-admission](./03-kubernetes-admission/)** - K8s资源验证

### 高级路径（⭐⭐⭐⭐）

1. **性能优化示例** - 待添加

---

## 🚀 快速开始

### 1. 安装OPA

```bash
# macOS
brew install opa

# Linux
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod +x opa
sudo mv opa /usr/local/bin/

# Windows
# 下载 https://openpolicyagent.org/downloads/latest/opa_windows_amd64.exe
# 重命名为 opa.exe 并添加到PATH
```

### 2. 运行示例

```bash
# 选择一个示例
cd examples/02-basic-rbac

# 运行测试
opa test . -v

# 评估策略
opa eval -i input_admin.json -d policy.rego -d data.json "data.rbac.allow"

# 格式化代码
opa fmt -w .
```

### 3. 调试技巧

```bash
# 查看中间结果
opa eval -d policy.rego "data.rbac.user_permissions"

# 详细解释
opa eval -i input.json -d policy.rego "data.rbac.allow" --explain full

# 性能分析
opa eval -i input.json -d policy.rego "data.rbac.allow" --profile
```

---

## 📖 示例详情

### [01-hello-world](./01-hello-world/) ⭐

**学习内容**:

- Rego基本语法（规则、默认值）
- `input`和`data`的区别
- 编写单元测试

**代码示例**:

```rego
package example

import rego.v1

default allow := false

allow if {
    input.message == "world"
}
```

---

### [02-basic-rbac](./02-basic-rbac/) ⭐⭐

**学习内容**:

- Set操作（`contains`、`in`）
- 数据驱动策略
- 权限继承模型

**权限矩阵**:

| 角色 | read | write | delete | admin |
|---|---|---|---|---|
| admin | ✅ | ✅ | ✅ | ✅ |
| editor | ✅ | ✅ | ❌ | ❌ |
| viewer | ✅ | ❌ | ❌ | ❌ |

**代码示例**:

```rego
package rbac

import rego.v1

user_permissions contains permission if {
    some permission in data.roles[input.user.role].permissions
}

allow if {
    input.action in user_permissions
}
```

**测试覆盖**:

- 所有角色的所有操作（✅ 12个测试）
- 边界情况（未知角色、空输入）
- 拒绝原因生成

---

### [03-kubernetes-admission](./03-kubernetes-admission/) ⭐⭐⭐

**学习内容**:

- K8s AdmissionReview结构
- 拒绝规则模式（`deny contains msg`）
- 复杂数据遍历

**验证规则**:

- ✅ 资源限制（CPU/内存）
- ✅ 镜像仓库白名单
- ✅ 禁止特权容器
- ✅ 必需标签（app、env、owner）
- ✅ Host配置限制

**代码示例**:

```rego
package kubernetes.admission

import rego.v1

deny contains msg if {
    some container in all_containers
    not container.resources.limits.cpu
    msg := sprintf("Container '%s' must specify CPU limits", [container.name])
}
```

**Gatekeeper集成**:
可转换为ConstraintTemplate部署到K8s集群。

---

## 🧪 测试详情

每个示例包含：

| 组件 | 说明 |
|------|------|
| `policy.rego` | 策略代码 |
| `policy_test.rego` | 单元测试（必需） |
| `input*.json` | 输入示例 |
| `data.json` | 静态数据（可选） |
| `README.md` | 详细文档 |

**测试统计**:

```text
总测试用例: 40+
正向测试: ~50%  # 应该允许的场景
负向测试: ~50%  # 应该拒绝的场景
边界测试: ~10%  # 边界和异常情况
```

---

## 💡 最佳实践

从示例中学到的模式：

### 1. Default Deny（默认拒绝）

```rego
default allow := false  # 安全第一
```

### 2. Set-based规则

```rego
# 使用contains定义集合
user_permissions contains permission if {
    # ...
}
```

### 3. 拒绝规则模式

```rego
# K8s场景：收集所有拒绝原因
deny contains msg if {
    # 条件
    msg := "拒绝原因"
}
```

### 4. 辅助函数

```rego
# 简化复杂逻辑
is_admin if {
    input.user.role == "admin"
}
```

---

## 🔧 扩展练习

### 练习1：扩展RBAC

在`02-basic-rbac`基础上添加：

- 资源级别权限（只能操作自己的资源）
- 时间窗口限制（仅工作时间允许操作）

### 练习2：K8s策略增强

在`03-kubernetes-admission`基础上添加：

- 镜像标签验证（禁止`:latest`）
- 资源配额限制（CPU不超过4核）
- 命名空间策略（不同NS不同规则）

### 练习3：创建新示例

选择场景创建自己的策略：

- API网关授权（JWT + RBAC）
- 数据访问控制（行级权限）
- CI/CD管道审批

---

## 📚 相关文档

### 本项目文档

- [Rego语法规范](../docs/02-语言模型/02.1-Rego语法规范.md)
- [策略设计模式](../docs/08-最佳实践/08.1-策略设计模式.md)
- [性能优化指南](../docs/08-最佳实践/08.2-性能优化指南.md)
- [学习路线图](../docs/LEARNING_PATH.md)
- [快速参考](../docs/QUICK_REFERENCE.md)

### 生产案例

- [电商API授权实战](../docs/09-生产实战/09.1-电商API授权实战.md)
- [生产案例汇总](../PRODUCTION_CASES.md)
- [部署检查清单](../CHECKLIST.md)

### 官方资源

- [OPA官方文档](https://www.openpolicyagent.org/docs/latest/)
- [Rego Playground](https://play.openpolicyagent.org/)
- [OPA GitHub](https://github.com/open-policy-agent/opa)

---

## ✅ CI/CD集成

所有示例通过GitHub Actions自动测试：

```yaml
# .github/workflows/test-examples.yml
name: Test Examples
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install OPA
        run: |
          curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
          chmod +x opa
      - name: Test All Examples
        run: |
          for dir in examples/*/; do
            cd "$dir"
            ../../opa test *.rego || exit 1
            cd ../..
          done
```

**测试状态**: ![CI](https://github.com/your-repo/workflows/test-examples/badge.svg)

---

## 🤝 贡献新示例

欢迎贡献！请确保：

**必需文件**:

```text
examples/XX-example-name/
├── README.md              # 详细说明
├── policy.rego            # 策略代码
├── policy_test.rego       # 单元测试
├── input.json             # 输入示例
└── data.json              # 静态数据（可选）
```

**质量要求**:

- ✅ 测试覆盖率 > 80%
- ✅ 通过CI测试
- ✅ 包含详细README
- ✅ 遵循[最佳实践](../docs/08-最佳实践/08.1-策略设计模式.md)

**提交流程**:

1. Fork项目
2. 创建新示例
3. 本地测试通过
4. 提交Pull Request

参见 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解详情。

---

## ❓ 常见问题

**Q: 示例运行报错怎么办？**

A: 检查OPA版本（需v0.55+）：

```bash
opa version
# 如果版本过低，更新OPA
```

**Q: 如何在自己的项目中使用？**

A: 复制示例作为起点：

```bash
cp -r examples/02-basic-rbac my-policy
cd my-policy
# 修改policy.rego
opa test . -v
```

**Q: 性能如何？**

A: 简单策略评估通常<1ms。复杂场景参考[性能优化指南](../docs/08-最佳实践/08.2-性能优化指南.md)。

---

## 📊 路线图

### 已完成 ✅

- [x] 01-hello-world
- [x] 02-basic-rbac
- [x] 03-kubernetes-admission

### 进行中 🚧

- [ ] 04-envoy-authz (API网关授权)
- [ ] 05-performance-optimization (性能优化)

### 计划中 📋

- [ ] 06-data-filtering (数据过滤)
- [ ] 07-multi-tenancy (多租户)
- [ ] 08-cicd-pipeline (CI/CD管道)

---

**最后更新**: 2025-10-21  
**贡献者**: 项目维护团队  
**License**: 与主项目相同

---

Happy Learning! 🎉 如有问题，请提交[Issue](../../issues)或查看[FAQ](../docs/FAQ.md)。
