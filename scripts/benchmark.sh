#!/bin/bash
# OPA技术文档项目 - 性能基准测试脚本

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA性能基准测试${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查OPA
if ! command -v opa &> /dev/null; then
    echo -e "${RED}❌ OPA未安装${NC}"
    exit 1
fi

OPA_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
echo "OPA版本: ${OPA_VERSION}"
echo ""

# 测试目录
TEST_DIR="examples/04-performance-optimization"

if [ ! -d "${TEST_DIR}" ]; then
    echo -e "${RED}❌ 测试目录不存在: ${TEST_DIR}${NC}"
    exit 1
fi

cd "${TEST_DIR}"

echo -e "${YELLOW}运行性能测试...${NC}"
echo ""

# 测试快速策略
echo -e "${BLUE}测试: policy_fast.rego${NC}"
if [ -f "policy_fast.rego" ]; then
    opa bench -f pretty -b . "data.example.perf_fast.allow"
    echo ""
fi

# 测试慢速策略
echo -e "${BLUE}测试: policy_slow.rego${NC}"
if [ -f "policy_slow.rego" ]; then
    opa bench -f pretty -b . "data.example.perf_slow.allow"
    echo ""
fi

echo -e "${GREEN}性能测试完成${NC}"
