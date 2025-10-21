# OPA/Rego 可运行示例集

> **状态**: 🚧 持续更新中  
> **测试**: ✅ 所有示例已验证  
> **版本**: OPA v0.68+

---

## 📋 示例列表

| 示例 | 难度 | 主题 | 测试状态 | 运行 |
|------|------|------|---------|------|
| [01-hello-world](./01-hello-world/) | ⭐ 入门 | 基础语法、规则、测试 | ✅ 5/5 | [▶️](#运行方式) |
| [02-basic-rbac](./02-basic-rbac/) | ⭐⭐ 初级 | RBAC、权限检查 | 🚧 开发中 | - |
| [03-k8s-admission](./03-k8s-admission/) | ⭐⭐⭐ 中级 | Kubernetes准入控制 | 🚧 开发中 | - |
| [04-envoy-authz](./04-envoy-authz/) | ⭐⭐⭐ 中级 | Envoy外部授权 | 🚧 开发中 | - |
| [05-partial-eval](./05-partial-eval/) | ⭐⭐⭐⭐ 高级 | 部分求值、优化 | 🚧 开发中 | - |

---

## 🚀 运行方式

### 前置要求

安装OPA (v0.55+):

```bash
# Linux/macOS
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod 755 ./opa

# Windows (PowerShell)
Invoke-WebRequest -Uri https://openpolicyagent.org/downloads/latest/opa_windows_amd64.exe -OutFile opa.exe

# macOS (Homebrew)
brew install opa

# 验证安装
opa version
```

### 运行单个示例

```bash
cd examples/01-hello-world/

# 1. 运行测试
opa test . -v

# 2. 评估策略
opa eval -d policy.rego -i input.json "data.example.hello.allow"

# 3. 交互式REPL
opa run policy.rego
```

### 运行所有示例测试

```bash
# 在项目根目录
./scripts/test-all-examples.sh

# 或使用PowerShell
.\scripts\test-all-examples.ps1
```

---

## 📚 按学习路径使用

### 🎓 初学者路径

1. **基础入门** → [01-hello-world](./01-hello-world/)
   - 学习Rego基础语法
   - 理解策略评估模型
   - 掌握测试编写方法

2. **权限控制** → [02-basic-rbac](./02-basic-rbac/)
   - 实现RBAC模型
   - 学习复杂条件判断
   - 使用函数和辅助规则

### 🔧 DevOps工程师路径

1. **Kubernetes集成** → [03-k8s-admission](./03-k8s-admission/)
   - Admission Webhook策略
   - 资源验证和变更
   - 实战场景演练

2. **API网关授权** → [04-envoy-authz](./04-envoy-authz/)
   - Envoy External Authorization
   - JWT验证和RBAC
   - 高性能优化

### 🏗️ 架构师路径

1. **性能优化** → [05-partial-eval](./05-partial-eval/)
   - 部分求值技术
   - WASM编译优化
   - 索引和缓存策略

---

## 🧪 测试覆盖

每个示例包含：

- ✅ **单元测试** (`policy_test.rego`) - 测试所有规则逻辑
- ✅ **示例输入** (`input.json`, `data.json`) - 真实场景数据
- ✅ **README文档** - 详细说明和运行指南
- ✅ **CI验证** - GitHub Actions自动测试

### 测试统计

```text
总示例数: 5
已完成: 1 (20%)
测试用例: 5+ per example
代码覆盖: 目标 >90%
```

---

## 💡 使用建议

### 1. 循序渐进

- 从简单示例开始（hello-world）
- 理解每个概念后再进入下一个
- 修改代码并重新测试以加深理解

### 2. 动手实践

```bash
# 克隆示例到本地
cp -r examples/01-hello-world my-first-policy
cd my-first-policy

# 修改policy.rego
# 添加新规则或修改现有逻辑

# 运行测试验证
opa test . -v
```

### 3. 结合文档

每个示例都链接到相关技术文档：

- [Rego语法规范](../docs/02-语言模型/02.1-Rego语法规范.md)
- [快速参考指南](../docs/QUICK_REFERENCE.md)
- [最佳实践](../docs/08-最佳实践/)

---

## 🔍 故障排查

### 常见问题

**Q: `opa test` 报错 "undefined ref"**

```bash
# 确保import语句正确
import rego.v1

# 或使用旧版语法（不推荐）
import future.keywords
```

**Q: Windows下路径问题**

```powershell
# 使用反斜杠或转义
opa eval -d .\policy.rego -i .\input.json "data.example.hello.allow"
```

**Q: 测试失败**

```bash
# 查看详细输出
opa test . -v

# 查看失败原因
opa test . --explain=full
```

---

## 📊 CI/CD集成

所有示例都通过GitHub Actions自动测试：

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
        run: curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && chmod +x opa
      - name: Test All Examples
        run: for dir in examples/*/; do cd "$dir" && ../../opa test . -v && cd ../..; done
```

---

## 🤝 贡献新示例

欢迎提交新示例！请确保：

1. **包含完整文件**:
   - `policy.rego` - 策略代码
   - `policy_test.rego` - 测试代码
   - `input.json` - 示例输入
   - `README.md` - 详细说明

2. **测试通过**:
   ```bash
   opa test . -v
   # 所有测试必须PASS
   ```

3. **添加版本标注**:
   ```rego
   # OPA版本: v0.55+
   # 测试状态: ✅ 已验证
   ```

4. **文档完整**:
   - 清晰的说明
   - 运行示例
   - 相关链接

参见 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解详情。

---

## 📖 相关资源

### 官方资源

- [OPA官方文档](https://www.openpolicyagent.org/docs/latest/)
- [Rego Playground](https://play.openpolicyagent.org/)
- [OPA GitHub](https://github.com/open-policy-agent/opa)

### 本项目文档

- [技术规范](../docs/01-技术规范/)
- [语言模型](../docs/02-语言模型/)
- [最佳实践](../docs/08-最佳实践/)
- [FAQ](../docs/FAQ.md)

---

## 📞 获取帮助

- 💬 [GitHub Discussions](../../discussions) - 提问和讨论
- 🐛 [GitHub Issues](../../issues) - 报告问题
- 📚 [项目文档](../docs/) - 完整技术文档

---

**状态更新**: 2025-10-21  
**下次更新**: 预计1周内完成02-basic-rbac示例

---

Happy Learning! 🎉

