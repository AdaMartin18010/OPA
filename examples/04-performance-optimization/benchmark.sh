#!/bin/bash
# Performance benchmark script for OPA v1.4.0
# Last verified: 2026-03-19

set -e

echo "==================================="
echo "OPA Performance Optimization Demo"
echo "==================================="
echo ""

# 检查OPA是否安装
if ! command -v opa &> /dev/null; then
    echo "❌ OPA not found. Please install OPA first."
    echo "   Visit: https://www.openpolicyagent.org/docs/latest/#running-opa"
    exit 1
fi

echo "✅ OPA version: $(opa version | head -n1)"
echo ""

# 测试慢版本
echo "==> Testing SLOW version (with full table scan)"
echo "------------------------------------------------"
opa bench \
    -d policy_slow.rego \
    -d data.json \
    -i input.json \
    --count 1000 \
    --format json \
    "data.authz_slow.allow" \
    | jq -r '"Queries/sec: " + (.histogram_timer_opa_rego_query_hz.mean | tostring) + "\nP99 latency: " + ((.histogram_timer_opa_rego_query_ns.p99 / 1000000) | tostring) + "ms"'

echo ""
echo ""

# 测试快版本
echo "==> Testing FAST version (with index optimization)"
echo "------------------------------------------------"
opa bench \
    -d policy_fast.rego \
    -d data.json \
    -i input.json \
    --count 1000 \
    --format json \
    "data.authz_fast.allow" \
    | jq -r '"Queries/sec: " + (.histogram_timer_opa_rego_query_hz.mean | tostring) + "\nP99 latency: " + ((.histogram_timer_opa_rego_query_ns.p99 / 1000000) | tostring) + "ms"'

echo ""
echo ""

# 计算改进
echo "==> Performance Comparison"
echo "-------------------------"
SLOW_QPS=$(opa bench -d policy_slow.rego -d data.json -i input.json --count 1000 --format json "data.authz_slow.allow" | jq '.histogram_timer_opa_rego_query_hz.mean')
FAST_QPS=$(opa bench -d policy_fast.rego -d data.json -i input.json --count 1000 --format json "data.authz_fast.allow" | jq '.histogram_timer_opa_rego_query_hz.mean')

IMPROVEMENT=$(echo "scale=1; $FAST_QPS / $SLOW_QPS" | bc)
echo "Performance improvement: ${IMPROVEMENT}x faster! 🚀"

echo ""
echo "==================================="
echo "✅ Benchmark completed!"
echo "==================================="
echo ""
echo "💡 Key takeaways:"
echo "  1. Use indexed lookups instead of full table scans"
echo "  2. Put cheap checks first"
echo "  3. Avoid repeated computations"
echo "  4. Use Sets instead of Arrays for membership checks"
echo ""
echo "📚 Learn more:"
echo "  - README.md for detailed explanations"
echo "  - ../../docs/08-最佳实践/08.2-性能优化指南.md"
echo ""

