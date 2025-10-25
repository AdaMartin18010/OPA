# 🤝 贡献指南

> **欢迎参与OPA技术文档项目！**  
> 本指南将帮助您快速上手，成为项目贡献者。

---

## 📋 目录

- [行为准则](#行为准则)
- [如何贡献](#如何贡献)
- [贡献类型](#贡献类型)
- [开发流程](#开发流程)
- [代码规范](#代码规范)
- [文档规范](#文档规范)
- [提交规范](#提交规范)
- [Pull Request流程](#pull-request流程)
- [贡献者荣誉](#贡献者荣誉)
- [获取帮助](#获取帮助)

---

## 🌟 行为准则

### 我们的承诺

我们承诺为所有人提供一个开放、友好、多元和包容的环境。

### 基本准则

- ✅ 尊重不同的观点和经验
- ✅ 接受建设性的批评
- ✅ 关注社区的最佳利益
- ✅ 对其他社区成员表现出同理心
- ❌ 使用性别化语言或图像
- ❌ 人身攻击或政治攻击
- ❌ 公开或私下骚扰
- ❌ 未经许可发布他人信息

---

## 🎯 如何贡献

### 1. 报告问题

发现问题？请通过以下方式报告：

- 🐛 [Bug报告](../../issues/new?template=bug_report.yml) - 文档错误、代码bug
- 📖 [文档改进](../../issues/new?template=documentation.yml) - 内容不清晰、需要补充
- ❓ [问题咨询](../../issues/new?template=question.yml) - 使用疑问

### 2. 提出建议

有好想法？欢迎分享：

- ✨ [功能建议](../../issues/new?template=feature_request.yml) - 新功能、新主题
- 💡 [想法讨论](../../discussions/new?category=ideas) - 创意交流
- 🌟 [案例展示](../../discussions/new?category=showcase) - 分享您的项目

### 3. 贡献代码/文档

准备动手？请查看：

- 📝 [Good First Issue](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) - 适合新手
- 🆘 [Help Wanted](../../issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) - 需要帮助
- 🏆 [Hacktoberfest](../../issues?q=is%3Aissue+is%3Aopen+label%3Ahacktoberfest) - 活动任务

---

## 🛠️ 贡献类型

### 1. 文档贡献 📖

**适合**: 所有人，无需编程经验

**贡献方式**:

- ✍️ 修正拼写、语法错误
- 📝 改进表达，让内容更清晰
- 📚 补充缺失的章节
- 🌍 翻译成其他语言
- 📊 添加图表、流程图

**示例**:

```markdown
# 修改前
这个函数用于计算结果

# 修改后  
`array.slice(array, startIndex, stopIndex)` 函数用于截取数组的子集，
返回从 `startIndex`（包含）到 `stopIndex`（不包含）的元素。
```

### 2. 代码示例贡献 💻

**适合**: 熟悉OPA/Rego的开发者

**贡献方式**:

- 🧪 添加新的代码示例
- ✅ 增加测试用例
- 🐛 修复示例bug
- ⚡ 优化性能
- 🔧 改进配置

**要求**:

- 包含完整的README说明
- 至少5个测试用例
- 通过CI/CD自动测试
- 提供运行说明

**示例结构**:

```text
examples/07-new-example/
├── README.md          # 详细说明
├── policy.rego        # 策略代码
├── policy_test.rego   # 单元测试
├── data.json          # 测试数据
├── input.json         # 输入示例
└── demo.sh            # 运行脚本
```

### 3. 工具/脚本贡献 🔧

**适合**: 熟悉自动化的开发者

**贡献方式**:

- 🤖 CI/CD改进
- 📊 监控脚本
- 🔍 验证工具
- 📈 分析脚本

### 4. 社区贡献 👥

**适合**: 所有人

**贡献方式**:

- 💬 回答问题（Issues/Discussions）
- 📢 分享项目
- 🎤 演讲分享
- 📝 撰写博客

---

## 🚀 开发流程

### 准备环境

```bash
# 1. Fork项目
# 在GitHub上点击 "Fork" 按钮

# 2. 克隆仓库
git clone https://github.com/YOUR_USERNAME/OPA.git
cd OPA

# 3. 添加上游仓库
git remote add upstream https://github.com/AdaMartin18010/OPA.git

# 4. 创建分支
git checkout -b feature/your-feature-name
```

### 本地开发

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev

# 在浏览器中访问 http://localhost:8080
```

### 测试代码示例

```bash
# 安装OPA（如果还没有）
# macOS
brew install opa

# Linux
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static
chmod +x opa
sudo mv opa /usr/local/bin/

# 运行测试
opa test examples/01-hello-world/ -v
opa test examples/02-basic-rbac/ -v
# ...测试所有示例

# 运行所有测试
npm test
```

### 构建文档

```bash
# 构建生产版本
npm run docs:build

# 预览构建结果
npm run docs:serve
```

---

## 📐 代码规范

### Rego代码规范

```rego
# ✅ 好的示例
import rego.v1

# 包名使用小写，用点分隔
package example.rbac

# 使用有意义的规则名
allow if {
    # 使用4个空格缩进
    user_has_permission
    resource_matches
}

# 辅助规则使用下划线命名
user_has_permission if {
    some role in input.user.roles
    role == "admin"
}

# ❌ 避免的做法
# 1. 不要使用Rego v0语法
allow = true {  # 旧语法
    input.user == "admin"
}

# 2. 避免单字母变量
allow if {
    some x in input.y  # 不清晰
}

# 3. 避免过于复杂的规则
allow if {
    # 超过20行的规则应该拆分
}
```

### 测试规范

```rego
# 测试文件命名: *_test.rego
package example.rbac_test

import rego.v1
import data.example.rbac

# 测试名称清晰描述测试场景
test_admin_can_access_all_resources if {
    result := rbac.allow with input as {
        "user": {"roles": ["admin"]},
        "resource": "sensitive-data"
    }
    result == true
}

# 每个测试应该独立，可以单独运行
test_user_cannot_access_admin_resources if {
    result := rbac.allow with input as {
        "user": {"roles": ["user"]},
        "resource": "admin-panel"
    }
    result == false
}

# 测试边界情况
test_missing_user_roles_denies_access if {
    result := rbac.allow with input as {
        "user": {},
        "resource": "data"
    }
    result == false
}
```

### JSON/YAML格式

```json
{
  "user": {
    "id": "user-123",
    "name": "Alice",
    "roles": ["editor", "viewer"]
  }
}
```

- 使用2空格缩进
- 键名使用snake_case
- 保持一致性

---

## 📝 文档规范

### Markdown规范

```markdown
# 一级标题 - 每个文档只有一个

## 二级标题 - 主要章节

### 三级标题 - 子章节

#### 四级标题 - 详细内容

##### 五级标题 - 很少使用

## 格式规范

- **加粗** 用于强调关键概念
- *斜体* 用于引入新术语（首次）
- `代码` 用于代码片段、文件名、函数名
- [链接](url) 使用相对路径

## 代码块

```rego
# 使用语言标识符
package example

allow if {
    input.user == "admin"
}
```

## 表格

| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 数据 | 数据 | 数据 |

## 列表

1. 有序列表项
2. 第二项

- 无序列表项
- 第二项

## 警告框

> **⚠️ 注意**: 重要提示
> 
> **✅ 提示**: 有用建议
> 
> **❌ 警告**: 避免的做法
```

### 文档结构

```markdown
# 文档标题

> **简介**: 一句话描述本文档内容  
> **适用版本**: OPA v0.68+  
> **难度等级**: ⭐⭐⭐ 中级  
> **预计阅读时间**: 30分钟

---

## 📋 目录

- [概述](#概述)
- [核心概念](#核心概念)
- [实践示例](#实践示例)
- [最佳实践](#最佳实践)
- [常见问题](#常见问题)

---

## 概述

[概述内容]

## 核心概念

### 子概念1

[内容]

### 子概念2

[内容]

## 实践示例

### 示例1: [标题]

[代码和说明]

## 最佳实践

- ✅ 推荐做法
- ❌ 避免做法

## 常见问题

### Q: [问题]

A: [答案]

---

**参考资料**:

- [链接1](url)
- [链接2](url)

**相关文档**:

- [文档1](../path/to/doc.md)
- [文档2](../path/to/doc.md)
```

### 中英文混排规范

```markdown
# ✅ 正确示例

OPA（Open Policy Agent）是一个开源的策略引擎。

使用 `rego.v1` 语法可以启用新特性。

Kubernetes 集成需要 v1.23+ 版本。

# ❌ 错误示例

OPA(Open Policy Agent)是一个开源的策略引擎。  # 缺少空格

使用`rego.v1`语法可以启用新特性。  # 中文与代码间需要空格
```

**规则**:

1. 中文与英文之间加空格
2. 中文与数字之间加空格
3. 中文与代码之间加空格
4. 标点符号使用中文全角（。，；：？！）
5. 英文内容使用英文标点（., ;: ?!）

---

## 📊 提交规范

### Commit Message格式

```text
<type>(<scope>): <subject>

<body>

<footer>
```

### Type类型

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | feat: 添加Envoy集成示例 |
| `fix` | Bug修复 | fix: 修正RBAC示例中的权限判断 |
| `docs` | 文档更新 | docs: 更新API规范文档 |
| `style` | 格式调整 | style: 统一代码缩进格式 |
| `refactor` | 重构 | refactor: 优化部分求值示例 |
| `test` | 测试相关 | test: 增加K8s示例测试用例 |
| `chore` | 构建/工具 | chore: 更新依赖版本 |
| `perf` | 性能优化 | perf: 优化查询性能 |

### Scope范围

- `docs` - 文档
- `examples` - 代码示例
- `ci` - CI/CD
- `config` - 配置文件

### 示例

```bash
# 好的提交消息
feat(examples): 添加数据过滤示例

添加了示例06-data-filtering，展示行级权限控制。
- 包含50+测试用例
- 支持多租户数据隔离
- 提供完整README文档

Closes #42

# 简单提交
docs: 修正拼写错误

# 破坏性变更
feat(rego)!: 迁移到Rego v1语法

BREAKING CHANGE: 所有示例代码已迁移到Rego v1语法
```

---

## 🔄 Pull Request流程

### 1. 提交前检查

```bash
# 格式检查
npm run lint

# 运行测试
npm test

# 构建文档
npm run docs:build
```

### 2. 创建PR

1. Push到您的Fork仓库

```bash
git push origin feature/your-feature-name
```

2. 在GitHub上创建Pull Request

3. 填写PR模板

```markdown
## 变更类型

- [ ] 文档更新
- [ ] 新增示例
- [ ] Bug修复
- [ ] 功能增强

## 变更说明

[描述您的变更]

## 测试

- [ ] 已通过本地测试
- [ ] 已添加单元测试
- [ ] 已更新相关文档

## 关联Issue

Closes #123

## 检查清单

- [ ] 代码符合规范
- [ ] 测试通过
- [ ] 文档已更新
- [ ] Commit message规范
```

### 3. Code Review

- 响应审查意见
- 及时更新PR
- 保持讨论友好

### 4. 合并

- 等待维护者审核
- CI/CD检查通过
- 获得批准后合并

---

## 🏆 贡献者荣誉

### 荣誉等级

| 等级 | 徽章 | 条件 |
|------|------|------|
| 新手贡献者 | 🌱 | 首次PR合并 |
| 活跃贡献者 | 🌟 | 5+ PR合并 |
| 核心贡献者 | 💎 | 20+ PR合并 |
| 维护者 | 👑 | 长期活跃，负责审核 |

### 贡献者列表

感谢所有贡献者！您的名字将出现在：

- 项目README
- 贡献者页面
- 发布说明

### 特殊贡献奖励

- 🎖️ 最佳文档贡献奖
- 🏅 最佳代码示例奖
- 🥇 社区之星

---

## ❓ 获取帮助

### 遇到问题？

- 📖 查看 [FAQ](docs/FAQ.md)
- 💬 加入 [GitHub Discussions](../../discussions)
- ❓ 提问 [Question Issue](../../issues/new?template=question.yml)

### 技术交流

- 💻 代码问题: [Stack Overflow](https://stackoverflow.com/questions/tagged/open-policy-agent)
- 🐛 Bug报告: [GitHub Issues](../../issues)
- 💡 功能建议: [GitHub Discussions](../../discussions)

### 联系维护者

- 📧 Email: [maintainer@example.com](mailto:maintainer@example.com)
- 💬 Discussions: [@维护者](../../discussions)

---

## 📚 相关资源

### 学习资源

- [OPA官方文档](https://www.openpolicyagent.org/docs/latest/)
- [Rego Playground](https://play.openpolicyagent.org/)
- [OPA GitHub](https://github.com/open-policy-agent/opa)

### 开发工具

- [VSCode OPA插件](https://marketplace.visualstudio.com/items?itemName=tsandall.opa)
- [IntelliJ OPA插件](https://plugins.jetbrains.com/plugin/16645-open-policy-agent)

---

## 📜 许可证

本项目采用 [Apache 2.0](LICENSE) 许可证。

贡献代码即表示您同意将您的贡献纳入此许可证。

---

## 🙏 致谢

感谢您考虑为OPA技术文档项目做出贡献！

每一个贡献，无论大小，都让项目变得更好。

**🎉 让我们一起推动Policy-as-Code技术在中文社区的发展！**

---

**最后更新**: 2025-10-25  
**版本**: v1.0  
**维护者**: OPA中文文档团队
