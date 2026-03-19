# OPA技术文档项目 - 资源中心

> **适用版本**: v2.6.0  
> **最后更新**: 2026年3月19日

---

## 📚 学习资源

### 官方资源

| 资源 | 链接 | 描述 |
|------|------|------|
| OPA官网 | https://www.openpolicyagent.org/ | 官方网站 |
| OPA GitHub | https://github.com/open-policy-agent/opa | 源码仓库 |
| OPA文档 | https://www.openpolicyagent.org/docs/latest/ | 官方文档 |
| Rego Playground | https://play.openpolicyagent.org/ | 在线编辑器 |

### 本项目的核心文档

#### 入门必读
- [README.md](README.md) - 项目概览
- [docs/00-总览与索引.md](docs/00-总览与索引.md) - 完整导航
- [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) - 快速参考
- [docs/LEARNING_PATH.md](docs/LEARNING_PATH.md) - 学习路线

#### 安全必读
- [docs/12-理论实践/12.6-CVE-2025-46569安全通告.md](docs/12-理论实践/12.6-CVE-2025-46569安全通告.md)
- [VERSION_COMPATIBILITY.md](VERSION_COMPATIBILITY.md)
- [CHECKLIST.md](CHECKLIST.md)

#### 进阶阅读
- [docs/02-语言模型/02.1-Rego语法规范.md](docs/02-语言模型/02.1-Rego语法规范.md)
- [docs/03-实现架构/](docs/03-实现架构/) - 实现架构章节
- [docs/10-源码分析/](docs/10-源码分析/) - 源码分析章节

---

## 🛠️ 工具资源

### 开发工具

| 工具 | 用途 | 安装 |
|------|------|------|
| OPA | 策略引擎 | `make install-opa` |
| Node.js | 文档构建 | 官方下载 |
| Docker | 容器化 | 官方下载 |
| Git | 版本控制 | 官方下载 |
| VS Code | 代码编辑 | 官方下载 |

### VS Code插件推荐

```json
{
  "recommendations": [
    "tsandall.opa",           // OPA插件
    "yzhang.markdown-all-in-one",  // Markdown增强
    "shd101wyy.markdown-preview-enhanced", // Markdown预览
    "davidanson.vscode-markdownlint",    // Markdown检查
    "streetsidesoftware.code-spell-checker" // 拼写检查
  ]
}
```

### 浏览器扩展

- **OPA Playground Helper** - 辅助OPA Playground使用
- **JSON Formatter** - JSON格式化
- **Markdown Reader** - Markdown阅读器

---

## 📖 阅读清单

### 初学者路径

**第1周：基础入门**
- [ ] [README.md](README.md)
- [ ] [docs/00-总览与索引.md](docs/00-总览与索引.md)
- [ ] [docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)
- [ ] [examples/01-hello-world/](examples/01-hello-world/)

**第2周：核心概念**
- [ ] [docs/02-语言模型/02.1-Rego语法规范.md](docs/02-语言模型/02.1-Rego语法规范.md)
- [ ] [docs/07-概念图谱/07.1-核心概念定义.md](docs/07-概念图谱/07.1-核心概念定义.md)
- [ ] [examples/02-basic-rbac/](examples/02-basic-rbac/)

**第3周：实践应用**
- [ ] [docs/05-应用场景/05.1-访问控制(RBAC).md](docs/05-应用场景/05.1-访问控制(RBAC).md)
- [ ] [examples/03-kubernetes-admission/](examples/03-kubernetes-admission/)

### 进阶路径

**阶段1：深入理解**
- [ ] [docs/03-实现架构/](docs/03-实现架构/)
- [ ] [docs/06-形式化证明/](docs/06-形式化证明/)

**阶段2：生产实践**
- [ ] [docs/09-生产实战/](docs/09-生产实战/)
- [ ] [PRODUCTION_CASES.md](PRODUCTION_CASES.md)

**阶段3：源码研究**
- [ ] [docs/10-源码分析/](docs/10-源码分析/)
- [ ] [docs/11-算法深度/](docs/11-算法深度/)

---

## 🎓 学习课程

### 视频教程 (规划中)

| 课程 | 时长 | 难度 | 内容 |
|------|------|------|------|
| OPA快速入门 | 15分钟 | ⭐ | 基础概念和安装 |
| Rego语法精讲 | 30分钟 | ⭐⭐ | 语法详解和实践 |
| K8s集成实战 | 45分钟 | ⭐⭐⭐ | Kubernetes集成 |
| 性能优化技巧 | 30分钟 | ⭐⭐⭐⭐ | 优化策略和工具 |

### 实战练习

```bash
# 练习1: Hello World
cd examples/01-hello-world
opa test . -v

# 练习2: RBAC
cd examples/02-basic-rbac
opa test . -v

# 练习3: K8s
cd examples/03-kubernetes-admission
opa test . -v
```

---

## 🔗 外部链接

### 社区资源

| 资源 | 链接 |
|------|------|
| OPA Slack | https://slack.openpolicyagent.org/ |
| OPA Twitter | https://twitter.com/openpolicyagent |
| CNCF | https://www.cncf.io/projects/open-policy-agent/ |
| Stack Overflow | https://stackoverflow.com/questions/tagged/open-policy-agent |

### 相关项目

| 项目 | 描述 | 链接 |
|------|------|------|
| Gatekeeper | K8s策略控制器 | https://github.com/open-policy-agent/gatekeeper |
| Conftest | 配置测试工具 | https://github.com/open-policy-agent/conftest |
| OPA Playground | 在线编辑器 | https://play.openpolicyagent.org/ |

### 博客和文章

- [OPA官方博客](https://blog.openpolicyagent.org/)
- [CNCF博客](https://www.cncf.io/blog/)
- [Kubernetes博客](https://kubernetes.io/blog/)

---

## 📥 下载资源

### 项目下载

```bash
# 克隆完整项目
git clone https://github.com/AdaMartin18010/OPA.git

# 下载特定版本
git clone --branch v2.6.0 https://github.com/AdaMartin18010/OPA.git

# 下载ZIP
wget https://github.com/AdaMartin18010/OPA/archive/refs/tags/v2.6.0.zip
```

### OPA下载

```bash
# Linux
curl -L -o opa https://openpolicyagent.org/downloads/v1.4.0/opa_linux_amd64_static

# macOS
curl -L -o opa https://openpolicyagent.org/downloads/v1.4.0/opa_darwin_amd64

# Windows
# 下载: https://openpolicyagent.org/downloads/v1.4.0/opa_windows_amd64.exe
```

### Docker镜像

```bash
# 拉取OPA镜像
docker pull openpolicyagent/opa:1.4.0

# 拉取项目镜像
docker pull ghcr.io/adamartin18010/opa-docs:latest
```

---

## 🆘 支持资源

### 获取帮助

| 渠道 | 链接 | 用途 |
|------|------|------|
| GitHub Issues | [新建Issue](../../issues/new) | 报告问题 |
| GitHub Discussions | [参与讨论](../../discussions) | 技术交流 |
| 文档反馈 | docs/反馈表单 | 文档建议 |

### 常见问题

查看 [docs/FAQ.md](docs/FAQ.md) 获取25个常见问题的解答。

### 故障排除

查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 获取详细的故障排除指南。

---

## 📝 贡献资源

### 如何贡献

1. **文档改进**
   - 修复拼写错误
   - 改进表达
   - 添加示例

2. **代码贡献**
   - 新示例
   - Bug修复
   - 功能增强

3. **社区参与**
   - 回答问题
   - 分享经验
   - 撰写博客

### 贡献指南

- [CONTRIBUTING.md](CONTRIBUTING.md) - 详细贡献指南
- [CONTRIBUTORS.md](CONTRIBUTORS.md) - 贡献者荣誉榜

---

## 🎯 快速参考卡片

### 常用命令速查

```bash
# 设置
make setup

# 测试
make test

# 构建
make build

# 部署
make deploy

# 验证
make verify

# 安全
make security-check
```

### 文档速查

```
技术规范  → docs/01-技术规范/
语言模型  → docs/02-语言模型/
实现架构  → docs/03-实现架构/
生产实战  → docs/09-生产实战/
安全通告  → docs/12-理论实践/12.6-CVE-2025-46569安全通告.md
```

---

**资源中心最后更新**: 2026年3月19日  
**维护者**: OPA中文文档团队

📚 **[浏览所有文档](docs/)** | 🛠️ **[查看工具](scripts/)** | 🆘 **[获取帮助](../../issues)**
