# 文档站点部署指南

> **目标**: 将OPA技术文档部署为在线可访问的网站  
> **技术栈**: VuePress v1.9 + GitHub Pages  
> **状态**: ✅ 配置完成，待部署

---

## 🎯 部署目标

将33篇技术文档、4个代码示例、工具文档等内容部署为：

- **在线文档站**: `https://YOUR_USERNAME.github.io/OPA/`
- **搜索功能**: 全文搜索支持
- **响应式设计**: PC/Mobile自适应
- **快速加载**: PWA + 代码分割
- **自动部署**: Git push 自动触发

---

## 📋 部署前准备

### 1. 安装Node.js

```bash
# 检查Node.js版本 (需要 v14+)
node --version

# 如果未安装，访问 https://nodejs.org/ 下载安装
```

### 2. 克隆仓库并安装依赖

```bash
# 克隆代码
git clone https://github.com/YOUR_USERNAME/OPA.git
cd OPA

# 安装依赖
npm install
```

### 3. 本地测试

```bash
# 启动开发服务器
npm run docs:dev

# 浏览器访问 http://localhost:8080
# 确保页面正常显示
```

---

## 🚀 部署方式

### 方式1：GitHub Actions 自动部署 (推荐)

#### 步骤1：配置GitHub仓库

1. **推送代码到GitHub**:
   ```bash
   git add .
   git commit -m "feat: 配置VuePress文档站点"
   git push origin main
   ```

2. **启用GitHub Pages**:
   - 访问仓库 Settings → Pages
   - Source: `Deploy from a branch`
   - Branch: 选择 `gh-pages` → `/ (root)`
   - 点击 Save

3. **等待自动部署**:
   - 进入 Actions 标签页
   - 查看 "Deploy Documentation" workflow
   - 等待构建完成（约2-5分钟）

4. **访问站点**:
   - https://YOUR_USERNAME.github.io/OPA/

#### 步骤2：验证部署

```bash
# 检查部署状态
curl -I https://YOUR_USERNAME.github.io/OPA/

# 应该返回 200 OK
```

---

### 方式2：手动部署

#### 步骤1：修改部署脚本

编辑 `deploy.sh`，替换仓库地址：

```bash
# 第24行
git push -f git@github.com:YOUR_USERNAME/OPA.git main:gh-pages
```

#### 步骤2：执行部署

```bash
# 添加执行权限
chmod +x deploy.sh

# 执行部署
./deploy.sh
```

#### 步骤3：配置GitHub Pages

同方式1的步骤2。

---

## ⚙️ 配置说明

### 1. 修改配置文件

**docs/.vuepress/config.js**:

```javascript
module.exports = {
  title: 'OPA 技术文档',
  description: 'Open Policy Agent - 全面技术分析与实践指南',
  base: '/OPA/',  // ⚠️ 仓库名，必须与GitHub仓库一致
  
  themeConfig: {
    repo: 'YOUR_USERNAME/OPA',  // ⚠️ 修改为你的仓库
    // ...
  }
}
```

**package.json**:

```json
{
  "name": "opa-docs",
  "version": "2.3.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/YOUR_USERNAME/OPA.git"  // ⚠️ 修改
  },
  "homepage": "https://YOUR_USERNAME.github.io/OPA/"  // ⚠️ 修改
}
```

### 2. 自定义域名 (可选)

如果有自定义域名：

1. **创建CNAME文件**:
   ```bash
   echo "docs.yourdomain.com" > docs/.vuepress/public/CNAME
   ```

2. **DNS配置**:
   - 添加CNAME记录: `docs.yourdomain.com` → `YOUR_USERNAME.github.io`

3. **GitHub Pages设置**:
   - Settings → Pages → Custom domain
   - 输入: `docs.yourdomain.com`
   - 勾选 "Enforce HTTPS"

---

## 📊 部署验证清单

部署完成后，检查以下功能：

- [ ] **首页正常显示**
  - 访问 https://YOUR_USERNAME.github.io/OPA/
  
- [ ] **导航栏功能**
  - 点击各导航链接正常跳转
  
- [ ] **侧边栏展开/折叠**
  - 侧边栏分组正常展开
  
- [ ] **文档内容正常**
  - 随机打开3-5篇文档
  - 检查代码高亮、表格、图片
  
- [ ] **搜索功能**
  - 使用搜索框搜索关键词
  - 结果正常显示
  
- [ ] **代码复制功能**
  - 悬停代码块出现复制按钮
  - 点击可复制代码
  
- [ ] **返回顶部按钮**
  - 滚动页面出现按钮
  - 点击滚动到顶部
  
- [ ] **移动端适配**
  - 使用手机或调整浏览器窗口
  - 布局自适应正常
  
- [ ] **页面加载速度**
  - 首次加载 < 3秒
  - 切换页面 < 1秒

---

## 🐛 常见问题

### 问题1：404错误

**现象**: 首页能访问，其他页面404

**原因**: `base` 配置不正确

**解决**:
```javascript
// config.js
base: '/OPA/',  // 确保与仓库名一致，且以/开头和结尾
```

### 问题2：样式丢失

**现象**: 页面显示但没有样式

**原因**: 静态资源路径错误

**解决**:
1. 检查 `base` 配置
2. 清理缓存重新构建:
   ```bash
   rm -rf dist node_modules
   npm install
   npm run docs:build
   ```

### 问题3：GitHub Actions失败

**现象**: Actions标签页显示红色×

**原因**: 
- 权限不足
- 配置错误

**解决**:
1. 检查 Settings → Actions → General
2. 确保 "Workflow permissions" 设置为 "Read and write permissions"
3. 重新触发 workflow

### 问题4：图片不显示

**现象**: 文档中的图片无法显示

**解决**:
1. 图片放在 `docs/.vuepress/public/images/`
2. Markdown中引用: `![alt](/images/xxx.png)`
3. 注意路径以 `/` 开头

---

## 🔄 更新文档

### 日常更新流程

```bash
# 1. 修改文档
# 编辑 docs/ 下的 .md 文件

# 2. 本地预览
npm run docs:dev

# 3. 提交代码
git add .
git commit -m "docs: 更新XXX文档"
git push origin main

# 4. 自动部署
# GitHub Actions 会自动构建并部署
# 约2-5分钟后生效
```

### 批量更新

```bash
# 1. 编辑多个文档

# 2. 构建测试
npm run docs:build
npm run docs:serve

# 3. 验证后提交
git add .
git commit -m "docs: 批量更新文档"
git push origin main
```

---

## 📈 性能优化

### 1. 启用PWA

已配置，用户可离线访问：

```javascript
// config.js
plugins: [
  ['@vuepress/pwa', {
    serviceWorker: true,
    updatePopup: true
  }]
]
```

### 2. 图片优化

```bash
# 压缩图片 (使用tinypng.com或其他工具)
# 建议图片大小:
# - 截图: < 200KB
# - 图标: < 50KB
# - 大图: < 500KB
```

### 3. 代码分割

VuePress自动处理，无需额外配置。

---

## 🎯 下一步优化

- [ ] **添加评论系统**
  - Gitalk / Vssue
  
- [ ] **添加统计分析**
  - Google Analytics
  - 百度统计
  
- [ ] **添加全文搜索**
  - Algolia DocSearch (免费)
  
- [ ] **添加深色主题**
  - 主题切换按钮
  
- [ ] **国际化**
  - 中英文双语支持

---

## 📞 技术支持

如果部署过程中遇到问题：

1. **查看日志**:
   - GitHub Actions → 点击失败的workflow
   - 查看详细错误信息

2. **本地调试**:
   ```bash
   npm run docs:build
   # 查看构建错误
   ```

3. **提交Issue**:
   - 访问 https://github.com/YOUR_USERNAME/OPA/issues
   - 描述问题和错误信息

---

**准备好了？开始部署吧！** 🚀

```bash
npm install
npm run docs:dev  # 本地预览
git push origin main  # 触发自动部署
```

