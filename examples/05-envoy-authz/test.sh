#!/usr/bin/env bash

# ================================================================
# Envoy + OPA 集成测试脚本
# ================================================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Envoy端点
ENVOY_URL="http://localhost:8000"

# 测试计数器
PASSED=0
FAILED=0

# ────────────────────────────────────────────────────────────────
# 辅助函数
# ────────────────────────────────────────────────────────────────

print_test() {
    echo -e "\n${YELLOW}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

# ────────────────────────────────────────────────────────────────
# 测试JWT Tokens
# ────────────────────────────────────────────────────────────────

# Admin token (有效，未过期)
ADMIN_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbjEiLCJyb2xlIjoiYWRtaW4iLCJleHAiOjk5OTk5OTk5OTl9.qTxSxN8ZNdXMGqI3L8Cqnj7HJZVMVa8Wqq2SqZ4GVQU"

# User token (有效，未过期)
USER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJ1c2VyIiwiZXhwIjo5OTk5OTk5OTk5fQ.2mD8L5D8ZQqY5L8ZQqY5L8ZQqY5L8ZQqY5L8ZQqY5L"

# ────────────────────────────────────────────────────────────────
# 检查服务状态
# ────────────────────────────────────────────────────────────────

echo "================================================"
echo "  Envoy + OPA 集成测试"
echo "================================================"

print_test "检查服务状态..."

# 检查Envoy
if curl -s -o /dev/null -w "%{http_code}" "$ENVOY_URL/health" | grep -q "200\|404"; then
    print_pass "Envoy服务运行中"
else
    print_fail "Envoy服务不可用"
    echo "请先运行: docker-compose up -d"
    exit 1
fi

# 检查OPA
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8181/health" | grep -q "200"; then
    print_pass "OPA服务运行中"
else
    print_fail "OPA服务不可用"
    exit 1
fi

# ────────────────────────────────────────────────────────────────
# 测试1：Admin权限
# ────────────────────────────────────────────────────────────────

print_test "测试Admin用户访问管理接口"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "$ENVOY_URL/api/admin/users")

if [ "$STATUS" = "200" ]; then
    print_pass "Admin可以访问 /api/admin/users (200)"
else
    print_fail "Admin访问被拒绝，状态码: $STATUS (期望200)"
fi

# ────────────────────────────────────────────────────────────────
# 测试2：User受限权限
# ────────────────────────────────────────────────────────────────

print_test "测试User用户访问自己的资源"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $USER_TOKEN" \
    "$ENVOY_URL/api/users/profile")

if [ "$STATUS" = "200" ]; then
    print_pass "User可以访问 /api/users/profile (200)"
else
    print_fail "User访问被拒绝，状态码: $STATUS (期望200)"
fi

# ────────────────────────────────────────────────────────────────
# 测试3：User不能访问管理接口
# ────────────────────────────────────────────────────────────────

print_test "测试User用户访问管理接口（应被拒绝）"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $USER_TOKEN" \
    "$ENVOY_URL/api/admin/users")

if [ "$STATUS" = "403" ]; then
    print_pass "User不能访问 /api/admin/users (403)"
else
    print_fail "预期拒绝但返回: $STATUS (期望403)"
fi

# ────────────────────────────────────────────────────────────────
# 测试4：无Token访问
# ────────────────────────────────────────────────────────────────

print_test "测试无Token访问受保护资源（应被拒绝）"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$ENVOY_URL/api/users/profile")

if [ "$STATUS" = "403" ]; then
    print_pass "无Token访问被拒绝 (403)"
else
    print_fail "预期拒绝但返回: $STATUS (期望403)"
fi

# ────────────────────────────────────────────────────────────────
# 测试5：公开接口无需认证
# ────────────────────────────────────────────────────────────────

print_test "测试公开接口访问（无需Token）"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    "$ENVOY_URL/health")

if [ "$STATUS" = "200" ] || [ "$STATUS" = "404" ]; then
    print_pass "公开接口可访问 ($STATUS)"
else
    print_fail "公开接口访问失败: $STATUS"
fi

# ────────────────────────────────────────────────────────────────
# 测试6：无效Token
# ────────────────────────────────────────────────────────────────

print_test "测试无效Token（应被拒绝）"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer invalid.token.here" \
    "$ENVOY_URL/api/users/profile")

if [ "$STATUS" = "403" ]; then
    print_pass "无效Token被拒绝 (403)"
else
    print_fail "预期拒绝但返回: $STATUS (期望403)"
fi

# ────────────────────────────────────────────────────────────────
# 测试7：Admin访问用户接口
# ────────────────────────────────────────────────────────────────

print_test "测试Admin访问用户接口"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "$ENVOY_URL/api/users/settings")

if [ "$STATUS" = "200" ]; then
    print_pass "Admin可以访问用户接口 (200)"
else
    print_fail "Admin访问用户接口失败: $STATUS (期望200)"
fi

# ────────────────────────────────────────────────────────────────
# 测试8：通配符路径匹配
# ────────────────────────────────────────────────────────────────

print_test "测试通配符路径匹配"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $ADMIN_TOKEN" \
    "$ENVOY_URL/api/users/123/posts")

if [ "$STATUS" = "200" ]; then
    print_pass "Admin可以访问嵌套用户路径 (200)"
else
    print_fail "通配符路径匹配失败: $STATUS (期望200)"
fi

# ────────────────────────────────────────────────────────────────
# 测试总结
# ────────────────────────────────────────────────────────────────

echo ""
echo "================================================"
echo "  测试总结"
echo "================================================"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✨ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}⚠️  有测试失败，请检查日志${NC}"
    echo ""
    echo "调试命令："
    echo "  docker logs opa-envoy-proxy"
    echo "  docker logs opa-authz-service"
    exit 1
fi

