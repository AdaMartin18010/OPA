# VuePress 文档站点配置说明

> **配置日期**: 2025年10月21日  
> **VuePress版本**: v1.9.10  
> **状态**: ✅ 已配置完成

---

## 📦 安装与运行

### 1. 安装依赖

```bash
# 使用 npm
npm install

# 或使用 yarn
yarn install
```

### 2. 本地开发

```bash
# 启动开发服务器
npm run docs:dev

# 访问 http://localhost:8080
```

### 3. 构建生产版本

```bash
# 构建静态文件
npm run docs:build

# 输出到 dist/ 目录
```

### 4. 本地预览构建结果

```bash
# 预览生产版本
npm run docs:serve

# 访问 http://localhost:5000
```

---

## 🚀 部署到 GitHub Pages

### 方法1：手动部署

```bash
# 执行部署脚本
bash deploy.sh
```

**注意**: 需要先修改 `deploy.sh` 中的仓库地址。

### 方法2：自动部署 (推荐)

项目已配置 GitHub Actions 自动部署：

1. **确保仓库设置**:
   - 仓库 Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` → `/ (root)`

2. **推送代码触发部署**:

   ```bash
   git add .
   git commit -m "docs: 更新文档"
   git push origin main
   ```

3. **查看部署状态**:
   - Actions 标签页
   - 查看 "Deploy Documentation" workflow

4. **访问站点**:
   - <https://YOUR_USERNAME.github.io/OPA/>

---

## 📝 配置文件说明

### 目录结构

```text
docs/
├── .vuepress/
│   ├── config.js              # 核心配置文件
│   ├── enhanceApp.js          # 应用增强
│   ├── styles/
│   │   ├── index.styl         # 自定义样式
│   │   └── palette.styl       # 颜色主题
│   ├── public/                # 静态资源
│   └── README_VUEPRESS.md     # 本文档
│
├── 01-技术规范/                # 各模块文档
├── 02-语言模型/
├── ...
└── README.md                   # 首页
```

### 核心配置 (config.js)

**导航栏配置**:

- 首页、快速开始、FAQ、学习路径
- 代码示例下拉菜单
- GitHub 链接

**侧边栏配置**:

- 9个主要模块分组
- 自动折叠/展开
- 支持嵌套结构

**插件配置**:

- `back-to-top`: 返回顶部按钮
- `medium-zoom`: 图片缩放
- `nprogress`: 页面加载进度条
- `pwa`: PWA支持（离线访问）
- `search`: 内置搜索
- `code-copy`: 代码一键复制

---

## 🎨 自定义样式

### 修改主题色

编辑 `docs/.vuepress/styles/palette.styl`:

```stylus
$accentColor = #3eaf7c      // 主题色
$textColor = #2c3e50        // 文本色
$borderColor = #eaecef      // 边框色
```

### 添加自定义样式

编辑 `docs/.vuepress/styles/index.styl`:

```stylus
// 添加自定义CSS
.custom-class {
  color: red;
}
```

---

## 🔌 插件扩展

### 安装新插件

```bash
# 示例：安装评论插件
npm install -D @vssue/vuepress-plugin-vssue
npm install -D @vssue/api-github-v4
```

### 配置插件

在 `config.js` 的 `plugins` 数组中添加：

```javascript
plugins: [
  // 现有插件...
  [
    '@vssue/vuepress-plugin-vssue',
    {
      platform: 'github-v4',
      owner: 'YOUR_USERNAME',
      repo: 'OPA',
      clientId: 'YOUR_CLIENT_ID',
      clientSecret: 'YOUR_CLIENT_SECRET',
    }
  ]
]
```

---

## 📊 SEO优化

### 已配置的SEO

- ✅ 站点标题和描述
- ✅ Meta标签（author, keywords）
- ✅ 最后更新时间
- ✅ 规范化URL

### 进一步优化

1. **添加sitemap**:

   ```bash
   npm install -D vuepress-plugin-sitemap
   ```

2. **添加robots.txt**:
   在 `docs/.vuepress/public/` 创建 `robots.txt`

3. **添加Google Analytics**:

   ```javascript
   plugins: [
     ['@vuepress/google-analytics', {
       'ga': 'UA-XXXXX-X'
     }]
   ]
   ```

---

## 🐛 常见问题

### 1. 构建失败

**问题**: `npm run docs:build` 失败

**解决**:

```bash
# 清理缓存
rm -rf node_modules
rm -rf docs/.vuepress/.cache
rm -rf docs/.vuepress/.temp

# 重新安装
npm install
```

### 2. 图片不显示

**问题**: 本地开发图片显示正常，部署后不显示

**解决**:

- 图片放在 `docs/.vuepress/public/`
- 引用路径使用 `/images/xxx.png` (以/开头)

### 3. 路由404

**问题**: GitHub Pages部署后某些页面404

**解决**:

- 确保 `base` 配置正确: `/OPA/`
- 确保仓库名与配置匹配

### 4. 样式不生效

**问题**: 自定义样式没有应用

**解决**:

- 检查文件扩展名是否为 `.styl`
- 重启开发服务器
- 清理缓存后重新构建

---

## 📚 参考文档

- [VuePress官方文档](https://vuepress.vuejs.org/)
- [VuePress插件市场](https://vuepress.vuejs.org/plugin/)
- [VuePress主题开发](https://vuepress.vuejs.org/theme/)
- [GitHub Pages文档](https://docs.github.com/en/pages)

---

## 🎯 下一步计划

- [ ] 添加评论系统（Vssue/Gitalk）
- [ ] 添加统计分析（Google Analytics）
- [ ] 优化移动端体验
- [ ] 添加深色主题切换
- [ ] 国际化支持（i18n）
- [ ] 添加全文搜索（Algolia）

---

**配置完成！** 🎉

现在可以运行 `npm run docs:dev` 查看效果了！
