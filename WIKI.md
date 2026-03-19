# OPA技术文档项目 - Wiki

> **适用版本**: v2.6.0
> **最后更新**: 2026年3月19日

---

## 📚 Wiki导航

欢迎来到OPA技术文档项目Wiki！这里提供额外的信息和资源。

---

## 🎯 快速链接

### 核心Wiki页面

| 页面 | 描述 | 链接 |
|------|------|------|
| 主页 | 项目主页 | [README](README.md) |
| 导航 | 完整导航 | [NAVIGATION](NAVIGATION.md) |
| 索引 | 文档索引 | [PROJECT_INDEX](PROJECT_INDEX_v2.6.0.md) |
| API | API参考 | [API](API.md) |
| FAQ | 常见问题 | [FAQ](docs/FAQ.md) |

### 开发Wiki

| 页面 | 描述 | 链接 |
|------|------|------|
| 贡献指南 | 如何贡献 | [CONTRIBUTING](CONTRIBUTING.md) |
| 架构设计 | 项目架构 | [ARCHITECTURE](ARCHITECTURE.md) |
| 故障排除 | 问题解决 | [TROUBLESHOOTING](TROUBLESHOOTING.md) |
| 性能监控 | 性能指南 | [PERFORMANCE_MONITORING](PERFORMANCE_MONITORING.md) |

### 资源Wiki

| 页面 | 描述 | 链接 |
|------|------|------|
| 资源中心 | 学习资源 | [RESOURCES](RESOURCES.md) |
| 时间线 | 项目历史 | [TIMELINE](TIMELINE.md) |
| 仪表板 | 项目统计 | [DASHBOARD](DASHBOARD.md) |
| 徽章 | 项目徽章 | [BADGES](badges.md) |

---

## 📖 知识库

### Rego语言知识

#### 基础概念

- [Rego语法](docs/02-语言模型/02.1-Rego语法规范.md)
- [类型系统](docs/02-语言模型/02.2-类型系统.md)
- [内置函数](docs/02-语言模型/02.3-内置函数库.md)

#### 进阶主题

- [求值模型](docs/02-语言模型/02.4-求值模型.md)
- [策略设计模式](docs/08-最佳实践/08.1-策略设计模式.md)
- [性能优化](docs/08-最佳实践/08.2-性能优化指南.md)

### OPA集成知识

#### Kubernetes

- [K8s集成](docs/04-生态系统/04.1-Kubernetes集成.md)
- [Gatekeeper](docs/04-生态系统/04.2-Gatekeeper详解.md)
- [K8s示例](../examples/03-kubernetes-admission/)

#### API网关

- [API授权](docs/05-应用场景/05.2-API网关授权.md)
- [Envoy集成](../examples/05-envoy-authz/)

### 安全知识

- [CVE-2025-46569](docs/12-理论实践/12.6-CVE-2025-46569安全通告.md)
- [安全合规](docs/01-技术规范/01.5-安全合规标准.md)
- [安全加固](docs/12-理论实践/12.4-安全加固实践.md)

---

## 🛠️ 开发指南

### 设置开发环境

```bash
# 1. 克隆项目
git clone https://github.com/AdaMartin18010/OPA.git
cd OPA

# 2. 安装依赖
make setup

# 3. 验证安装
make verify
```

### 开发工作流

```
1. 创建分支
   git checkout -b feature/my-feature

2. 做出修改
   # 编辑文件...

3. 本地测试
   make test

4. 提交更改
   git commit -m "Add: 新功能"

5. 推送分支
   git push origin feature/my-feature

6. 创建PR
   # 在GitHub上创建Pull Request
```

---

## 📝 最佳实践

### 文档编写

- 使用清晰的标题结构
- 添加代码示例
- 提供上下文信息
- 保持更新

### 代码提交

- 写清晰的commit消息
- 一个commit一个功能
- 添加测试
- 通过CI检查

---

## 🤝 社区

### 参与方式

- ⭐ Star项目
- 🍴 Fork项目
- 🐛 提交Issue
- 💬 参与讨论
- 📝 提交PR

### 交流渠道

- [GitHub Discussions](../../discussions)
- [GitHub Issues](../../issues)
- 邮件列表 (规划中)

---

## 📅 项目时间线

查看完整的[项目时间线](TIMELINE.md)。

### 重要里程碑

- 2025-10-17: 项目启动
- 2025-10-18: 核心文档完成
- 2025-10-21: VuePress站点上线
- 2025-10-25: SEO优化完成
- 2026-03-19: 100%+完成

---

## 📊 项目统计

- 📚 114篇文档
- 💻 6个示例
- 🧪 200+测试
- 🔧 10个脚本
- ⭐ 7/5星评级

---

## 🎯 路线图

查看[路线图](ROADMAP.md)了解未来计划。

### 规划中

- [ ] 完整英文翻译
- [ ] 视频教程
- [ ] 在线Playground
- [ ] 社区论坛

---

**Wiki维护**: OPA中文文档团队
**最后更新**: 2026年3月19日
**版本**: v2.6.0

🏠 **[返回首页](README.md)** | 📚 **[浏览文档](docs/)** | 💬 **[参与讨论](../../discussions)**
