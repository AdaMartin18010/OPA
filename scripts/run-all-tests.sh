#!/bin/bash
# OPA技术文档项目 - 完整测试套件
# 运行所有测试并生成报告

set -e

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m' # No Color

# 项目信息
PROJECT_NAME="OPA技术文档"
PROJECT_VERSION="2.6.0"

# 计数器
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  ${PROJECT_NAME} v${PROJECT_VERSION} 测试套件${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查OPA版本
echo -e "${YELLOW}检查OPA版本...${NC}"
if ! command -v opa &> /dev/null; then
    echo -e "${RED}❌ OPA未安装${NC}"
    exit 1
fi

OPA_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
echo -e "${GREEN}✅ OPA版本: ${OPA_VERSION}${NC}"
echo ""

# 测试函数
run_test() {
    local test_name="$1"
    local test_dir="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${YELLOW}测试: ${test_name}${NC}"
    
    if cd "${test_dir}" && opa test . -v 2>/dev/null; then
        echo -e "${GREEN}  ✅ 通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        cd - > /dev/null
        return 0
    else
        echo -e "${RED}  ❌ 失败${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        cd - > /dev/null
        return 1
    fi
}

# 1. 测试所有示例
echo -e "${BLUE}1. 运行代码示例测试...${NC}"
echo ""

for dir in examples/*/; do
    if [ -f "${dir}policy_test.rego" ]; then
        example_name=$(basename "${dir}")
        run_test "${example_name}" "${dir}"
        echo ""
    fi
done

# 2. 验证Reg代码格式
echo -e "${BLUE}2. 验证Rego代码格式...${NC}"
echo ""

FORMAT_ERRORS=0
for rego_file in $(find examples/ -name "*.rego" -not -name "*_test.rego"); do
    if ! opa fmt -d "${rego_file}" > /dev/null 2>&1; then
        echo -e "${RED}  ❌ 格式错误: ${rego_file}${NC}"
        FORMAT_ERRORS=$((FORMAT_ERRORS + 1))
    fi
done

if [ $FORMAT_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ 所有Rego文件格式正确${NC}"
else
    echo -e "${RED}❌ 发现 ${FORMAT_ERRORS} 个格式错误${NC}"
fi
echo ""

# 3. 检查文档完整性
echo -e "${BLUE}3. 检查文档完整性...${NC}"
echo ""

REQUIRED_DOCS=(
    "README.md"
    "CHANGELOG.md"
    "CONTRIBUTING.md"
    "VERSION_COMPATIBILITY.md"
    "CHECKLIST.md"
    "docs/00-总览与索引.md"
    "docs/QUICK_REFERENCE.md"
    "docs/FAQ.md"
    "docs/LEARNING_PATH.md"
    "docs/GLOSSARY.md"
)

MISSING_DOCS=0
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ ! -f "${doc}" ]; then
        echo -e "${RED}  ❌ 缺失: ${doc}${NC}"
        MISSING_DOCS=$((MISSING_DOCS + 1))
    fi
done

if [ $MISSING_DOCS -eq 0 ]; then
    echo -e "${GREEN}✅ 所有必需文档存在${NC}"
else
    echo -e "${RED}❌ 发现 ${MISSING_DOCS} 个缺失文档${NC}"
fi
echo ""

# 4. 检查安全版本
echo -e "${BLUE}4. 检查安全版本...${NC}"
echo ""

OPA_MAJOR=$(echo ${OPA_VERSION} | cut -d. -f1)
OPA_MINOR=$(echo ${OPA_VERSION} | cut -d. -f2)

if [ "${OPA_MAJOR}" -gt 1 ] || ([ "${OPA_MAJOR}" -eq 1 ] && [ "${OPA_MINOR}" -ge 4 ]); then
    echo -e "${GREEN}✅ OPA版本安全 (>= v1.4.0, CVE-2025-46569已修复)${NC}"
else
    echo -e "${RED}⚠️  OPA版本过旧 (< v1.4.0), 存在CVE-2025-46569风险${NC}"
fi
echo ""

# 5. 生成测试报告
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  测试报告${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}测试统计:${NC}"
echo "  总测试数: ${TOTAL_TESTS}"
echo "  通过: ${PASSED_TESTS}"
echo "  失败: ${FAILED_TESTS}"
echo ""

if [ $FAILED_TESTS -eq 0 ] && [ $FORMAT_ERRORS -eq 0 ] && [ $MISSING_DOCS -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ 所有测试通过${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ❌ 部分测试失败${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi
