#!/bin/bash
# OPA技术文档项目 - 健康检查工具
# 全面检查项目健康状态

set -e

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA技术文档 - 健康检查${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

HEALTH_SCORE=0
MAX_SCORE=100

# 检查函数
check_component() {
    local name="$1"
    local status="$2"
    local score="$3"
    
    if [ "$status" = "ok" ]; then
        echo -e "${GREEN}✅${NC} $name (+$score分)"
        HEALTH_SCORE=$((HEALTH_SCORE + score))
    else
        echo -e "${RED}❌${NC} $name (0分)"
    fi
}

# 1. 检查核心文档
echo -e "${BLUE}1. 检查核心文档...${NC}"

CORE_DOCS=(
    "README.md"
    "CHANGELOG.md"
    "CONTRIBUTING.md"
    "docs/00-总览与索引.md"
    "docs/QUICK_REFERENCE.md"
    "docs/FAQ.md"
)

CORE_OK=true
for doc in "${CORE_DOCS[@]}"; do
    if [ ! -f "$doc" ]; then
        CORE_OK=false
        echo -e "${RED}  缺失: $doc${NC}"
    fi
done

check_component "核心文档" "$([ "$CORE_OK" = true ] && echo "ok" || echo "fail")" 15

# 2. 检查示例代码
echo -e "${BLUE}2. 检查示例代码...${NC}"

EXAMPLES_OK=true
for dir in examples/*/; do
    if [ ! -f "${dir}README.md" ]; then
        EXAMPLES_OK=false
        echo -e "${RED}  缺少README: $dir${NC}"
    fi
    if [ ! -f "${dir}policy.rego" ]; then
        EXAMPLES_OK=false
        echo -e "${RED}  缺少policy.rego: $dir${NC}"
    fi
done

check_component "示例代码" "$([ "$EXAMPLES_OK" = true ] && echo "ok" || echo "fail")" 15

# 3. 检查脚本工具
echo -e "${BLUE}3. 检查脚本工具...${NC}"

SCRIPTS=(
    "scripts/run-all-tests.sh"
    "scripts/verify-project.sh"
    "scripts/security-check.sh"
    "scripts/setup.sh"
)

SCRIPTS_OK=true
for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        SCRIPTS_OK=false
        echo -e "${RED}  缺失: $script${NC}"
    elif [ ! -x "$script" ]; then
        echo -e "${YELLOW}  警告: $script 不可执行${NC}"
    fi
done

check_component "脚本工具" "$([ "$SCRIPTS_OK" = true ] && echo "ok" || echo "fail")" 10

# 4. 检查配置文件
echo -e "${BLUE}4. 检查配置文件...${NC}"

CONFIGS=(
    "Makefile"
    "package.json"
    "docs/.vuepress/config.js"
)

CONFIGS_OK=true
for config in "${CONFIGS[@]}"; do
    if [ ! -f "$config" ]; then
        CONFIGS_OK=false
        echo -e "${RED}  缺失: $config${NC}"
    fi
done

check_component "配置文件" "$([ "$CONFIGS_OK" = true ] && echo "ok" || echo "fail")" 10

# 5. 检查CI/CD配置
echo -e "${BLUE}5. 检查CI/CD配置...${NC}"

if [ -d ".github/workflows" ] && [ -f ".github/workflows/test-examples.yml" ]; then
    check_component "CI/CD配置" "ok" 10
else
    check_component "CI/CD配置" "fail" 0
fi

# 6. 检查Docker配置
echo -e "${BLUE}6. 检查Docker配置...${NC}"

if [ -f "Dockerfile" ] && [ -f "docker-compose.yml" ]; then
    check_component "Docker配置" "ok" 10
else
    check_component "Docker配置" "fail" 0
fi

# 7. 检查依赖
echo -e "${BLUE}7. 检查依赖...${NC}"

DEPS_OK=true

# 检查Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}  ✅ Node.js: $NODE_VERSION${NC}"
else
    echo -e "${RED}  ❌ Node.js未安装${NC}"
    DEPS_OK=false
fi

# 检查OPA
if command -v opa &> /dev/null; then
    OPA_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
    echo -e "${GREEN}  ✅ OPA: $OPA_VERSION${NC}"
else
    echo -e "${YELLOW}  ⚠️  OPA未安装${NC}"
fi

check_component "依赖环境" "$([ "$DEPS_OK" = true ] && echo "ok" || echo "fail")" 10

# 8. 检查Git仓库
echo -e "${BLUE}8. 检查Git仓库...${NC}"

if [ -d ".git" ]; then
    check_component "Git仓库" "ok" 10
else
    check_component "Git仓库" "fail" 0
fi

# 9. 检查文档统计
echo -e "${BLUE}9. 文档统计...${NC}"

DOC_COUNT=$(find docs -name "*.md" 2>/dev/null | wc -l)
if [ "$DOC_COUNT" -gt 50 ]; then
    echo -e "${GREEN}  ✅ 文档数量: $DOC_COUNT 篇${NC}"
    check_component "文档数量" "ok" 10
else
    echo -e "${YELLOW}  ⚠️  文档数量较少: $DOC_COUNT 篇${NC}"
    check_component "文档数量" "fail" 0
fi

# 10. 生成健康报告
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  健康检查报告${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "健康评分: ${HEALTH_SCORE}/${MAX_SCORE}"

# 健康等级
if [ $HEALTH_SCORE -ge 90 ]; then
    GRADE="A+ (优秀)"
    COLOR="${GREEN}"
elif [ $HEALTH_SCORE -ge 80 ]; then
    GRADE="A (良好)"
    COLOR="${GREEN}"
elif [ $HEALTH_SCORE -ge 70 ]; then
    GRADE="B (一般)"
    COLOR="${YELLOW}"
elif [ $HEALTH_SCORE -ge 60 ]; then
    GRADE="C (及格)"
    COLOR="${YELLOW}"
else
    GRADE="D (不及格)"
    COLOR="${RED}"
fi

echo -e "健康等级: ${COLOR}${GRADE}${NC}"
echo ""

if [ $HEALTH_SCORE -ge 80 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ 项目健康状况良好${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
elif [ $HEALTH_SCORE -ge 60 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  ⚠️  项目健康度一般，建议改进${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ❌ 项目健康度较差，需要立即修复${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi
