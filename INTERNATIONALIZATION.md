# OPA技术文档项目 - 国际化(i18n)支持

> **适用版本**: v2.6.0
> **最后更新**: 2026年3月19日
> **状态**: 规划中

---

## 🌍 国际化路线图

### 支持语言规划

| 语言 | 代码 | 优先级 | 状态 | 进度 |
|------|------|--------|------|------|
| 中文 | zh-CN | P0 | ✅ 已完成 | 100% |
| 英文 | en-US | P1 | 🚧 规划中 | 14% |


---

## 📁 目录结构

```
docs/
├── .vuepress/
│   └── config.js              # i18n配置
├── zh/                        # 中文文档 (当前)
│   ├── README.md
│   ├── 00-总览与索引.md
│   └── ...
├── en/                        # 英文文档 (规划中)
│   ├── README.md
│   ├── 00-overview-and-index.md
│   └── ...
├── ja/                        # 日文文档 (未来)
│   └── ...
└── ...
```

---

## 🔧 VuePress i18n配置

### 基础配置

```javascript
// docs/.vuepress/config.js
module.exports = {
  locales: {
    '/': {
      lang: 'zh-CN',
      title: 'OPA 技术文档',
      description: 'Open Policy Agent 全面技术分析'
    },
    '/en/': {
      lang: 'en-US',
      title: 'OPA Technical Documentation',
      description: 'Comprehensive technical analysis of Open Policy Agent'
    }
  },

  themeConfig: {
    locales: {
      '/': {
        selectText: '选择语言',
        label: '简体中文',
        nav: [...],
        sidebar: {...}
      },
      '/en/': {
        selectText: 'Languages',
        label: 'English',
        nav: [...],
        sidebar: {...}
      }
    }
  }
}
```

---

## 📝 翻译指南

### 翻译原则

1. **准确性**: 技术术语准确，保持原意
2. **一致性**: 统一术语翻译，建立词汇表
3. **可读性**: 符合目标语言表达习惯
4. **完整性**: 保留所有代码示例和图表

### 术语词汇表

| 中文 | English | 日文 | 韩文 |
|------|---------|------|------|
| 策略 | Policy | ポリシー | 정책 |
| 规则 | Rule | ルール | 규칙 |
| 授权 | Authorization | 認可 | 인증 |
| 认证 | Authentication | 認証 | 인증 |
| 访问控制 | Access Control | アクセス制御 | 접근 제어 |
| 策略引擎 | Policy Engine | ポリシーエンジン | 정책 엔진 |
| 声明式 | Declarative | 宣言的 | 선언적 |
| 形式化 | Formalization | 形式化 | 형식화 |
| 语义 | Semantics | 意味論 | 의미론 |
| 求值 | Evaluation | 評価 | 평가 |

### 翻译流程

```
1. 文档选择
   ↓
2. 术语准备 (参考词汇表)
   ↓
3. 初稿翻译
   ↓
4. 技术审核
   ↓
5. 语言润色
   ↓
6. 格式检查
   ↓
7. 发布上线
```

---

## 🎯 英文翻译计划

### Phase 1: 核心文档 (14% 已完成)

- [x] 10篇核心文档已添加英文摘要
- [ ] README.md 完整翻译
- [ ] 00-Overview-and-Index.md
- [ ] QUICK_REFERENCE.md

### Phase 2: 技术规范 (规划中)

- [ ] 01.1-API-Specification.md
- [ ] 01.2-Bundle-Format.md
- [ ] 01.3-WASM-Compilation.md
- [ ] 01.4-Performance-Benchmarks.md
- [ ] 01.5-Security-Compliance.md

### Phase 3: 语言模型 (规划中)

- [ ] 02.1-Rego-Syntax.md
- [ ] 02.2-Type-System.md
- [ ] 02.3-Built-in-Functions.md
- [ ] 02.4-Evaluation-Model.md

### Phase 4: 实现架构 (规划中)

- [ ] 03.1-Lexical-Analysis.md
- [ ] 03.2-AST-and-IR.md
- [ ] 03.3-Compiler-Design.md
- [ ] 03.4-Top-Down-Evaluator.md
- [ ] 03.5-Indexing-and-Optimization.md
- [ ] 03.6-Partial-Evaluation.md

### Phase 5: 其他章节 (规划中)

- [ ] 04-Ecosystem/
- [ ] 05-Use-Cases/
- [ ] 06-Formal-Verification/
- [ ] 07-Concept-Map/
- [ ] 08-Best-Practices/
- [ ] 09-Production-Cases/
- [ ] 10-Source-Code-Analysis/
- [ ] 11-Algorithm-Depth/
- [ ] 12-Theory-and-Practice/

---

## 🛠️ 翻译工具

### 推荐工具

| 工具 | 用途 | 链接 |
|------|------|------|
| Crowdin | 协作翻译平台 | <https://crowdin.com/> |
| GitLocalize | Git集成翻译 | <https://gitlocalize.com/> |
| DeepL | AI翻译辅助 | <https://www.deepl.com/> |
| Google Translate | 参考翻译 | <https://translate.google.com/> |

### 本地化管理

```bash
# 安装vuepress-plugin-i18n
npm install -D vuepress-plugin-i18n

# 提取待翻译内容
npm run i18n:extract

# 合并翻译
npm run i18n:merge
```

---

## 👥 贡献者招募

### 我们需要

- **英文翻译者**: 将中文文档翻译为英文
- **日文翻译者**: 将中文文档翻译为日文
- **韩文翻译者**: 将中文文档翻译为韩文
- **审核者**: 审核翻译质量
- **术语专家**: 维护术语词汇表

### 如何参与

1. **Fork项目**
2. **创建翻译分支**:

   ```bash
   git checkout -b i18n/en-chapter-name
   ```

3. **进行翻译**
4. **提交Pull Request**
5. **等待审核合并**

### 翻译规范

```markdown
## 提交格式

[翻译] 英文 - 02.1-Rego语法规范

- 翻译章节: 02.1-Rego语法规范
- 目标语言: 英文
- 字数: ~8000字
- 审核人: @reviewer
```

---

## 📊 翻译进度追踪

### 整体进度

```
英文翻译进度:
[████░░░░░░░░░░░░░░░░] 14% (15/109篇)

日文翻译进度:
[░░░░░░░░░░░░░░░░░░░░] 0% (0/109篇)

韩文翻译进度:
[░░░░░░░░░░░░░░░░░░░░] 0% (0/109篇)
```

### 英文翻译详细进度

| 章节 | 状态 | 进度 |
|------|------|------|
| 核心摘要 | ✅ 完成 | 10/10 |
| 工具文档 | 🚧 进行中 | 1/4 |
| 技术规范 | 📋 计划中 | 0/5 |
| 语言模型 | 📋 计划中 | 0/4 |
| 实现架构 | 📋 计划中 | 0/6 |
| 生态系统 | 📋 计划中 | 0/2 |
| 应用场景 | 📋 计划中 | 0/2 |
| 形式化证明 | 📋 计划中 | 0/8 |
| 概念图谱 | 📋 计划中 | 0/1 |
| 最佳实践 | 📋 计划中 | 0/2 |
| 生产实战 | 📋 计划中 | 0/3 |
| 源码分析 | 📋 计划中 | 0/10 |
| 算法深度 | 📋 计划中 | 0/5 |
| 理论实践 | 📋 计划中 | 0/6 |

---

## 🔗 相关资源

### 参考翻译

- [Vue.js 中文文档](https://cn.vuejs.org/)
- [React 中文文档](https://zh-hans.react.dev/)
- [Kubernetes 中文文档](https://kubernetes.io/zh/)

### 翻译社区

- [开源翻译社区](https://github.com/opensource-guide)
- [技术文档翻译最佳实践](https://example.com)

---

## 📅 里程碑

| 日期 | 目标 | 状态 |
|------|------|------|
| 2025-12 | 英文核心文档30% | 📋 计划中 |
| 2026-03 | 英文核心文档60% | 📋 计划中 |
| 2026-06 | 英文核心文档100% | 📋 计划中 |
| 2026-09 | 日文翻译启动 | 📋 计划中 |
| 2026-12 | 多语言支持上线 | 📋 计划中 |

---

## 💬 联系我们

对国际化感兴趣？请联系我们：

- 📧 邮件: [创建讨论](../../discussions/new)
- 💬 Slack: [OPA中文社区]
- 🐦 Twitter: [@OPA中文文档]

---

**国际化负责人**: OPA中文文档团队
**最后更新**: 2026年3月19日
**状态**: 规划中

🌍 **[参与翻译](../../discussions)** | 📚 **[查看英文摘要](docs/)** | 🏠 **[返回首页](README.md)**
