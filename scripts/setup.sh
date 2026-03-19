#!/bin/bash
# OPA技术文档项目 - 初始化设置脚本
# 一键设置开发环境

set -e

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA技术文档项目 - 初始化设置${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查系统
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    SYSTEM="Linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM="macOS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    SYSTEM="Windows"
else
    SYSTEM="Unknown"
fi

echo -e "${YELLOW}检测到系统: ${SYSTEM}${NC}"
echo ""

# 1. 检查依赖
echo -e "${BLUE}1. 检查依赖...${NC}"

# 检查Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js: ${NODE_VERSION}${NC}"
else
    echo -e "${RED}❌ Node.js未安装${NC}"
    echo "请访问 https://nodejs.org/ 安装Node.js v18+"
    exit 1
fi

# 检查npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm: ${NPM_VERSION}${NC}"
else
    echo -e "${RED}❌ npm未安装${NC}"
    exit 1
fi

# 检查Git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | awk '{print $3}')
    echo -e "${GREEN}✅ Git: ${GIT_VERSION}${NC}"
else
    echo -e "${RED}❌ Git未安装${NC}"
    exit 1
fi

echo ""

# 2. 安装OPA
echo -e "${BLUE}2. 安装OPA...${NC}"

if command -v opa &> /dev/null; then
    OPA_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
    echo -e "${GREEN}✅ OPA已安装: ${OPA_VERSION}${NC}"
    
    # 检查版本
    OPA_MAJOR=$(echo ${OPA_VERSION} | cut -d. -f1)
    OPA_MINOR=$(echo ${OPA_VERSION} | cut -d. -f2)
    
    if [ "${OPA_MAJOR}" -lt 1 ] || ([ "${OPA_MAJOR}" -eq 1 ] && [ "${OPA_MINOR}" -lt 4 ]); then
        echo -e "${YELLOW}⚠️  OPA版本过旧，建议升级到v1.4.0+${NC}"
        echo "运行: make install-opa"
    fi
else
    echo -e "${YELLOW}⚠️  OPA未安装${NC}"
    echo "运行以下命令安装OPA:"
    echo "  make install-opa"
fi

echo ""

# 3. 安装项目依赖
echo -e "${BLUE}3. 安装项目依赖...${NC}"

if [ -f "package.json" ]; then
    echo "安装根目录依赖..."
    npm install
    echo -e "${GREEN}✅ 根目录依赖安装完成${NC}"
fi

if [ -d "docs" ] && [ -f "docs/package.json" ]; then
    echo "安装docs目录依赖..."
    cd docs && npm install && cd ..
    echo -e "${GREEN}✅ docs依赖安装完成${NC}"
fi

echo ""

# 4. 验证安装
echo -e "${BLUE}4. 验证安装...${NC}"

# 运行测试
if make test > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 测试通过${NC}"
else
    echo -e "${YELLOW}⚠️  测试未通过，可能需要配置${NC}"
fi

echo ""

# 5. 显示信息
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  设置完成${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}可用命令:${NC}"
echo "  make help       - 显示帮助"
echo "  make test       - 运行测试"
echo "  make dev        - 启动开发服务器"
echo "  make build      - 构建文档"
echo "  make verify     - 验证项目"
echo ""
echo -e "${GREEN}文档地址:${NC}"
echo "  本地: http://localhost:8080/OPA/"
echo "  在线: https://adamartin18010.github.io/OPA/"
echo ""
echo -e "${GREEN}项目已准备就绪!${NC}"
