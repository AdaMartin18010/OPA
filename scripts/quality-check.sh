#!/bin/bash
# OPA技术文档项目 - 文档质量检查工具
# 检查文档质量，包括格式、链接、内容等

set -e

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA技术文档 - 质量检查工具${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 计数器
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

# 检查函数
check_pass() {
    echo -e "${GREEN}✅${NC} $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

check_fail() {
    echo -e "${RED}❌${NC} $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

# 1. 检查文档格式
echo -e "${BLUE}1. 检查文档格式...${NC}"

# 检查Markdown标题格式
TITLE_ERRORS=0
for file in $(find docs -name "*.md"); do
    # 检查是否有H1标题
    if ! grep -q "^# " "$file"; then
        check_warn "缺少H1标题: $file"
        TITLE_ERRORS=$((TITLE_ERRORS + 1))
    fi
done

if [ $TITLE_ERRORS -eq 0 ]; then
    check_pass "所有文档都有H1标题"
else
    check_warn "$TITLE_ERRORS 个文档缺少H1标题"
fi

# 2. 检查代码块语言标记
echo -e "${BLUE}2. 检查代码块语言标记...${NC}"

CODE_BLOCK_ERRORS=0
for file in $(find docs -name "*.md"); do
    # 检查未标记语言的代码块
    if grep -q "^\s*\`\`\`\s*$" "$file"; then
        check_warn "发现未标记语言的代码块: $file"
        CODE_BLOCK_ERRORS=$((CODE_BLOCK_ERRORS + 1))
    fi
done

if [ $CODE_BLOCK_ERRORS -eq 0 ]; then
    check_pass "所有代码块都有语言标记"
else
    check_warn "$CODE_BLOCK_ERRORS 个文件有未标记的代码块"
fi

# 3. 检查图片alt文本
echo -e "${BLUE}3. 检查图片alt文本...${NC}"

IMAGE_ERRORS=0
for file in $(find docs -name "*.md"); do
    # 检查没有alt文本的图片
    if grep -E "!\[\]\(" "$file" > /dev/null 2>&1; then
        check_warn "发现没有alt文本的图片: $file"
        IMAGE_ERRORS=$((IMAGE_ERRORS + 1))
    fi
done

if [ $IMAGE_ERRORS -eq 0 ]; then
    check_pass "所有图片都有alt文本"
else
    check_warn "$IMAGE_ERRORS 个文件有图片缺少alt文本"
fi

# 4. 检查文档头部信息
echo -e "${BLUE}4. 检查文档头部信息...${NC}"

HEADER_ERRORS=0
for file in $(find docs -name "*.md"); do
    # 检查是否有版本信息
    if ! grep -q "适用版本" "$file" && ! grep -q "最后更新" "$file"; then
        # 跳过索引文件和README
        if [[ "$file" != *"README"* ]] && [[ "$file" != *"00-"* ]]; then
            check_warn "缺少头部信息: $file"
            HEADER_ERRORS=$((HEADER_ERRORS + 1))
        fi
    fi
done

if [ $HEADER_ERRORS -eq 0 ]; then
    check_pass "文档头部信息完整"
else
    check_warn "$HEADER_ERRORS 个文档缺少头部信息"
fi

# 5. 检查内部链接
echo -e "${BLUE}5. 检查内部链接...${NC}"

# 简单的链接格式检查
LINK_ERRORS=0
for file in $(find docs -name "*.md"); do
    # 检查空的链接
    if grep -E "\[\s*\]\(" "$file" > /dev/null 2>&1; then
        check_warn "发现空链接文本: $file"
        LINK_ERRORS=$((LINK_ERRORS + 1))
    fi
done

if [ $LINK_ERRORS -eq 0 ]; then
    check_pass "链接格式正确"
else
    check_warn "$LINK_ERRORS 个文件有链接问题"
fi

# 6. 检查文件命名规范
echo -e "${BLUE}6. 检查文件命名规范...${NC}"

NAMING_ERRORS=0
for file in $(find docs -name "*.md"); do
    filename=$(basename "$file")
    # 检查是否包含空格
    if [[ "$filename" == *" "* ]]; then
        check_warn "文件名包含空格: $file"
        NAMING_ERRORS=$((NAMING_ERRORS + 1))
    fi
done

if [ $NAMING_ERRORS -eq 0 ]; then
    check_pass "文件命名规范"
else
    check_warn "$NAMING_ERRORS 个文件名不规范"
fi

# 7. 统计文档信息
echo -e "${BLUE}7. 文档统计...${NC}"

DOC_COUNT=$(find docs -name "*.md" | wc -l)
WORD_COUNT=$(find docs -name "*.md" -exec wc -c {} + | tail -1 | awk '{print $1}')
WORD_COUNT_K=$((WORD_COUNT / 1000))

echo "   文档数量: $DOC_COUNT 篇"
echo "   总字数: $WORD_COUNT_K K"

# 8. 检查README更新
echo -e "${BLUE}8. 检查README更新...${NC}"

if grep -q "v2.6.0" README.md; then
    check_pass "README版本信息已更新"
else
    check_fail "README版本信息需要更新"
fi

# 9. 生成质量报告
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  质量检查报告${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}通过: ${CHECKS_PASSED}${NC}"
echo -e "${YELLOW}警告: ${WARNINGS}${NC}"
echo -e "${RED}失败: ${CHECKS_FAILED}${NC}"
echo ""

TOTAL=$((CHECKS_PASSED + CHECKS_FAILED))
if [ $TOTAL -gt 0 ]; then
    SCORE=$((CHECKS_PASSED * 100 / TOTAL))
    echo "质量评分: ${SCORE}/100"
fi

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✅ 质量检查通过${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 0
else
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  ⚠️  发现 ${CHECKS_FAILED} 个问题需要修复${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    exit 1
fi
