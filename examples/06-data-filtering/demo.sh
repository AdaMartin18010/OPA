#!/usr/bin/env bash

# ================================================================
# 数据过滤示例演示脚本
# ================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================"
echo "  数据过滤示例 - 行级权限控制"
echo "================================================"
echo ""

# ────────────────────────────────────────────────────────────────
# 演示1：全局管理员查看所有数据
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 1]${NC} 全局管理员查看所有数据"
echo -e "${BLUE}身份${NC}: 全局管理员 (admin-1)"
echo ""

opa eval -d policy.rego -d data.json -i input_admin.json \
  'data.filtering.allowed_records' --format pretty

echo ""
echo -e "${GREEN}✅ 管理员可以看到所有6条记录${NC}"
echo ""
sleep 2

# ────────────────────────────────────────────────────────────────
# 演示2：普通用户只看到自己的数据
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 2]${NC} 普通用户只看到自己的数据"
echo -e "${BLUE}身份${NC}: 普通用户 (user-1, tenant-a, team-1)"
echo ""

opa eval -d policy.rego -d data.json -i input_user.json \
  'data.filtering.allowed_records' --format pretty

echo ""
echo -e "${GREEN}✅ user-1只能看到自己的记录和公开记录${NC}"
echo ""
sleep 2

# ────────────────────────────────────────────────────────────────
# 演示3：团队管理员查看团队数据
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 3]${NC} 团队管理员查看团队数据"
echo -e "${BLUE}身份${NC}: 团队管理员 (team-manager-1, team-1)"
echo ""

opa eval -d policy.rego -d data.json -i input_team.json \
  'data.filtering.allowed_records' --format pretty

echo ""
echo -e "${GREEN}✅ 团队管理员可以看到team-1的所有数据${NC}"
echo ""
sleep 2

# ────────────────────────────────────────────────────────────────
# 演示4：数据脱敏
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 4]${NC} 数据脱敏 - 普通用户vs管理员"
echo ""

echo -e "${BLUE}普通用户看到的数据（已脱敏）:${NC}"
opa eval -d policy.rego -d data.json -i input_user.json \
  'data.filtering.filtered_records[0]' --format pretty

echo ""

echo -e "${BLUE}管理员看到的数据（完整）:${NC}"
opa eval -d policy.rego -d data.json -i input_admin.json \
  'data.filtering.filtered_records[0]' --format pretty

echo ""
echo -e "${GREEN}✅ 敏感字段（content, metadata）已对普通用户隐藏${NC}"
echo ""
sleep 2

# ────────────────────────────────────────────────────────────────
# 演示5：SQL WHERE子句生成
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 5]${NC} 生成SQL WHERE子句"
echo ""

echo -e "${BLUE}管理员的WHERE子句:${NC}"
opa eval -d policy.rego -i input_admin.json \
  'data.filtering.sql_where_clause'

echo ""

echo -e "${BLUE}普通用户的WHERE子句:${NC}"
opa eval -d policy.rego -i input_user.json \
  'data.filtering.sql_where_clause'

echo ""
echo -e "${GREEN}✅ 可以用于数据库查询优化，减少数据传输${NC}"
echo ""
sleep 2

# ────────────────────────────────────────────────────────────────
# 演示6：统计信息
# ────────────────────────────────────────────────────────────────

echo -e "${YELLOW}[演示 6]${NC} 数据统计"
echo ""

echo -e "${BLUE}普通用户可访问的记录数:${NC}"
opa eval -d policy.rego -d data.json -i input_user.json \
  'data.filtering.record_count'

echo ""

echo -e "${BLUE}管理员 - 按租户统计:${NC}"
opa eval -d policy.rego -d data.json -i input_admin.json \
  'data.filtering.records_by_tenant' --format pretty

echo ""
echo -e "${GREEN}✅ 提供了丰富的统计信息用于监控和审计${NC}"
echo ""

# ────────────────────────────────────────────────────────────────
# 总结
# ────────────────────────────────────────────────────────────────

echo "================================================"
echo "  演示完成"
echo "================================================"
echo ""
echo "关键收获:"
echo "1. ✅ 行级权限控制确保数据隔离"
echo "2. ✅ 多租户数据隔离防止数据泄露"
echo "3. ✅ 数据脱敏保护敏感信息"
echo "4. ✅ SQL生成优化数据库查询"
echo "5. ✅ 统计和审计支持合规要求"
echo ""
echo "下一步: 运行单元测试 'opa test . -v'"
echo ""

