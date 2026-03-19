#!/bin/bash
# OPA技术文档项目 - 安全检查脚本
# 检查项目安全配置和CVE修复状态

# 颜色定义
BLUE='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OPA技术文档项目 - 安全检查${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查OPA版本
echo -e "${YELLOW}1. 检查OPA版本...${NC}"
if command -v opa &> /dev/null; then
    OPA_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
    echo "   当前版本: ${OPA_VERSION}"
    
    # 解析版本号
    OPA_MAJOR=$(echo ${OPA_VERSION} | cut -d. -f1)
    OPA_MINOR=$(echo ${OPA_VERSION} | cut -d. -f2)
    
    if [ "${OPA_MAJOR}" -gt 1 ] || ([ "${OPA_MAJOR}" -eq 1 ] && [ "${OPA_MINOR}" -ge 4 ]); then
        echo -e "   ${GREEN}✅ 版本安全 (>= v1.4.0)${NC}"
        echo -e "   ${GREEN}✅ CVE-2025-46569已修复${NC}"
    else
        echo -e "   ${RED}❌ 版本过旧 (< v1.4.0)${NC}"
        echo -e "   ${RED}⚠️  存在CVE-2025-46569风险${NC}"
        echo ""
        echo -e "${YELLOW}升级建议:${NC}"
        echo "  curl -L -o opa https://openpolicyagent.org/downloads/v1.4.0/opa_linux_amd64_static"
        echo "  chmod 755 opa && sudo mv opa /usr/local/bin/"
    fi
else
    echo -e "   ${YELLOW}⚠️  OPA未安装${NC}"
fi
echo ""

# 检查安全文档
echo -e "${YELLOW}2. 检查安全文档...${NC}"

if [ -f "docs/12-理论实践/12.6-CVE-2025-46569安全通告.md" ]; then
    echo -e "   ${GREEN}✅ CVE-2025-46569安全通告存在${NC}"
else
    echo -e "   ${RED}❌ CVE-2025-46569安全通告缺失${NC}"
fi

if grep -q "CVE-2025-46569" README.md 2>/dev/null; then
    echo -e "   ${GREEN}✅ README.md包含安全警告${NC}"
else
    echo -e "   ${YELLOW}⚠️  README.md缺少安全警告${NC}"
fi

if grep -q "CVE-2025-46569" VERSION_COMPATIBILITY.md 2>/dev/null; then
    echo -e "   ${GREEN}✅ 版本兼容性文档包含安全信息${NC}"
else
    echo -e "   ${YELLOW}⚠️  版本兼容性文档缺少安全信息${NC}"
fi
echo ""

# 检查安全加固清单
echo -e "${YELLOW}3. 检查安全加固清单...${NC}"

if [ -f "CHECKLIST.md" ]; then
    SECURITY_ITEMS=$(grep -c "CVE-2025-46569\|安全\|漏洞" CHECKLIST.md || echo "0")
    echo "   安全检查项: ${SECURITY_ITEMS} 项"
    if [ ${SECURITY_ITEMS} -gt 10 ]; then
        echo -e "   ${GREEN}✅ 安全检查项充足${NC}"
    else
        echo -e "   ${YELLOW}⚠️  安全检查项可能不足${NC}"
    fi
else
    echo -e "   ${RED}❌ CHECKLIST.md不存在${NC}"
fi
echo ""

# 检查示例代码安全
echo -e "${YELLOW}4. 检查示例代码安全...${NC}"

INSECURE_PATTERNS=0

# 检查是否使用了不安全的模式
for rego_file in $(find examples/ -name "*.rego" 2>/dev/null); do
    # 检查是否使用了http.send (可能存在风险)
    if grep -q "http.send" "${rego_file}"; then
        echo -e "   ${YELLOW}⚠️  ${rego_file} 使用了http.send${NC}"
        INSECURE_PATTERNS=$((INSECURE_PATTERNS + 1))
    fi
done

if [ ${INSECURE_PATTERNS} -eq 0 ]; then
    echo -e "   ${GREEN}✅ 未发现明显不安全的代码模式${NC}"
else
    echo -e "   ${YELLOW}⚠️  发现 ${INSECURE_PATTERNS} 个需要关注的模式${NC}"
fi
echo ""

# 提供安全建议
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  安全建议${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}1. 立即行动:${NC}"
echo "   • 升级OPA到v1.4.0+"
echo "   • 阅读CVE-2025-46569安全通告"
echo "   • 运行安全检查: make security-check"
echo ""

echo -e "${GREEN}2. 部署前检查:${NC}"
echo "   • 查看CHECKLIST.md安全章节"
echo "   • 配置system.authz授权策略"
echo "   • 启用审计日志"
echo ""

echo -e "${GREEN}3. 持续监控:${NC}"
echo "   • 关注OPA安全公告"
echo "   • 定期运行安全扫描"
echo "   • 保持版本更新"
echo ""

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
