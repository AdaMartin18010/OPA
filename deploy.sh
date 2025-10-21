#!/usr/bin/env bash

# 确保脚本抛出遇到的错误
set -e

# 构建文档
echo "🔨 Building documentation..."
npm run docs:build

# 进入生成的文件夹
cd dist

# 创建.nojekyll文件（GitHub Pages）
touch .nojekyll

# 初始化git仓库
echo "📦 Initializing git repository..."
git init
git add -A
git commit -m 'deploy: 更新文档站点'

# 推送到GitHub Pages
echo "🚀 Deploying to GitHub Pages..."
# 替换YOUR_USERNAME和YOUR_REPO
git push -f git@github.com:YOUR_USERNAME/OPA.git main:gh-pages

cd -

echo "✅ 部署完成！"
echo "📖 文档站点: https://YOUR_USERNAME.github.io/OPA/"


