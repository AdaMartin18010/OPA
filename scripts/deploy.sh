#!/bin/bash
# OPA技术文档项目 - 部署脚本
# 部署文档到GitHub Pages

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA技术文档 - 部署脚本${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否在正确的目录
if [ ! -f "docs/.vuepress/config.js" ]; then
    echo -e "${RED}❌ 错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

# 检查npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ 错误: 需要安装npm${NC}"
    exit 1
fi

# 构建
echo -e "${YELLOW}1. 构建文档站点...${NC}"
cd docs
npm run build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ 构建失败${NC}"
    exit 1
fi

echo -e "${GREEN}✅ 构建成功${NC}"
echo ""

# 检查dist目录
if [ ! -d ".vuepress/dist" ]; then
    echo -e "${RED}❌ 错误: 构建输出目录不存在${NC}"
    exit 1
fi

# 部署到GitHub Pages
echo -e "${YELLOW}2. 部署到GitHub Pages...${NC}"

# 使用gh-pages或手动部署
cd .vuepress/dist

# 初始化git仓库
git init
git add -A
git commit -m "Deploy documentation v2.6.0"

# 推送到gh-pages分支
git push -f git@github.com:AdaMartin18010/OPA.git master:gh-pages

echo -e "${GREEN}✅ 部署完成${NC}"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  部署信息${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "站点地址: https://adamartin18010.github.io/OPA/"
echo "版本: v2.6.0"
echo "时间: $(date)"
echo ""
echo -e "${GREEN}✅ 部署成功!${NC}"
