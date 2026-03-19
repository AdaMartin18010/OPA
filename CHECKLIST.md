# OPA生产环境检查清单

> **用途**: 生产环境部署前的完整检查清单  
> **适用**: 所有OPA生产部署场景  
> **版本**: v1.0 (2025-10-21)

---

## 📋 使用说明

在将OPA部署到生产环境之前，请仔细检查以下每一项。建议：

- ✅ **打印**本清单，逐项检查
- ✅ **团队Review**，多人检查
- ✅ **记录证据**，保存检查结果
- ✅ **定期复查**，每季度回顾

---

## 1️⃣ 策略开发阶段

### 1.1 策略设计

- [ ] **需求明确**: 业务需求文档完整
- [ ] **设计评审**: 架构设计通过团队评审
- [ ] **安全评估**: 安全团队审批通过
- [ ] **性能预估**: 完成性能影响评估

### 1.2 代码质量

- [ ] **语法检查**: 所有策略通过`opa check`
- [ ] **格式规范**: 使用`opa fmt`格式化
- [ ] **Rego v1**: 使用`import rego.v1`语法
- [ ] **代码审查**: 至少2人Code Review
- [ ] **静态分析**: 无复杂度告警
- [ ] **命名规范**: 遵循项目命名约定

**验证命令**:

```bash
# 语法检查
opa check --strict policy.rego

# 格式检查
opa fmt -d policy.rego

# 复杂度检查
opa check --metrics policy.rego
```

### 1.3 测试覆盖

- [ ] **单元测试**: 覆盖率≥90%
- [ ] **边界测试**: 覆盖边界条件
- [ ] **负面测试**: 测试拒绝场景
- [ ] **性能测试**: 基准测试通过
- [ ] **集成测试**: 与系统集成测试
- [ ] **压力测试**: 高负载测试通过

**验证命令**:

```bash
# 运行测试
opa test . -v --coverage

# 性能基准
opa bench policy.rego

# 输出覆盖率报告
opa test . --coverage --format=json
```

**覆盖率要求**:

```json
{
  "coverage": {
    "lines": 95.5,  // 目标: ≥90%
    "not_covered": []
  }
}
```

---

## 2️⃣ 部署配置阶段

### 2.1 版本兼容性

- [ ] **OPA版本**: 使用推荐版本(v0.55+)
- [ ] **CVE-2025-46569修复**: OPA版本 >= v1.4.0
- [ ] **Rego版本**: 使用v1.0语法
- [ ] **依赖检查**: 所有依赖版本兼容
- [ ] **向后兼容**: 不破坏现有功能
- [ ] **版本文档**: 记录版本要求

**CVE-2025-46569漏洞检查**:

```bash
# 检查当前OPA版本
opa version

# 版本对比 (需要 >= 1.4.0)
CURRENT_VERSION=$(opa version | grep "Version:" | awk '{print $2}')
if [[ "$CURRENT_VERSION" < "1.4.0" ]]; then
    echo "🔴 存在CVE-2025-46569漏洞风险! 请立即升级到 v1.4.0+"
    exit 1
else
    echo "✅ 版本安全，已修复CVE-2025-46569"
fi
```

**参考**: [VERSION_COMPATIBILITY.md](VERSION_COMPATIBILITY.md)

### 2.2 部署架构

- [ ] **部署模式**: 选择合适模式(Sidecar/集中式/WASM)
- [ ] **高可用**: 至少2个副本
- [ ] **负载均衡**: 配置健康检查
- [ ] **资源限制**: 设置CPU/内存限制
- [ ] **网络策略**: 配置网络隔离
- [ ] **服务发现**: 注册到服务注册中心
- [ ] **网络隔离验证**: CVE-2025-46569网络层防护已配置

**CVE-2025-46569网络防护配置**:

```yaml
# Kubernetes NetworkPolicy - 限制OPA网络访问
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opa-restrict-access
  namespace: opa
spec:
  podSelector:
    matchLabels:
      app: opa
  policyTypes:
  - Ingress
  ingress:
  # 只允许来自特定服务的访问
  - from:
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8181
```

**Kubernetes资源配置**:

```yaml
resources:
  requests:
    memory: "128Mi"  # 最小值
    cpu: "100m"      # 最小值
  limits:
    memory: "512Mi"  # 最大值
    cpu: "500m"      # 最大值

replicas: 3          # 最少2个副本
```

### 2.3 策略分发

- [ ] **Bundle配置**: Bundle服务配置正确
- [ ] **签名验证**: 启用Bundle签名验证
- [ ] **更新策略**: 配置合理的轮询间隔
- [ ] **缓存策略**: 启用本地缓存
- [ ] **回滚机制**: 准备回滚方案
- [ ] **版本控制**: Bundle版本化管理
- [ ] **安全Bundle验证**: CVE-2025-46569缓解策略已包含在Bundle中

**OPA配置示例**:

```yaml
bundles:
  authz:
    service: bundle-server
    resource: bundles/authz.tar.gz
    signing:
      keyid: my_key
      scope: write
    polling:
      min_delay_seconds: 60
      max_delay_seconds: 120
    persist: true  # 启用持久化
```

---

## 3️⃣ 安全配置阶段

### 3.1 认证授权

- [ ] **API认证**: OPA API启用认证
- [ ] **TLS加密**: 启用TLS/mTLS
- [ ] **证书管理**: 证书有效期>30天
- [ ] **密钥轮转**: 定期轮转密钥
- [ ] **最小权限**: 服务账户最小权限
- [ ] **网络隔离**: 限制网络访问
- [ ] **system.authz配置**: CVE-2025-46569授权策略已启用

**CVE-2025-46569授权策略配置 (system/authz.rego)**:

```rego
package system.authz

import rego.v1

# 默认拒绝所有请求
default allow := false

# 允许的健康检查
allow if {
    input.path == ["health"]
    input.method == "GET"
}

allow if {
    input.path == ["v1", "health"]
    input.method == "GET"
}

# ========== HTTP Data API 路径验证 (CVE-2025-46569防护) ==========

# 允许的路径前缀
allowed_path_prefixes := {"public", "app", "api/v1", "api/v2"}

# 有效路径字符：只允许字母、数字、下划线
valid_path_characters := `^[a-zA-Z0-9_]+$`

# 安全的Data API访问控制
allow if {
    input.method in ["GET", "POST"]
    input.path[0] == "v1"
    input.path[1] == "data"
    
    # 验证路径深度 (防御深路径DoS)
    count(input.path) <= 6
    
    # 验证每个路径段 (防御路径注入)
    every segment in array.slice(input.path, 2, count(input.path)) {
        regex.match(valid_path_characters, segment)
    }
    
    # 验证前缀
    input.path[2] in allowed_path_prefixes
    
    # 需要身份认证
    input.identity
}

# ========== 管理员权限 ==========

allow if {
    input.identity.role == "admin"
    input.method in ["GET", "POST", "PUT", "DELETE"]
    input.path[0] == "v1"
}

# ========== 拒绝可疑请求 (CVE-2025-46569检测) ==========

# 拒绝包含特殊字符的路径
deny contains "Invalid path characters: quotes or semicolons detected" if {
    some segment in input.path
    regex.match(`["';%]`, segment)
}

# 拒绝过深的路径 (防御DoS)
deny contains "Path too deep: maximum depth exceeded" if {
    count(input.path) > 8
}

# 拒绝尝试访问system命名空间
deny contains "Access denied: system namespace restricted" if {
    "system" in input.path
    input.identity.role != "admin"
}

# 拒绝URL编码的引号 (CVE-2025-46569攻击特征)
deny contains "Invalid request: encoded special characters detected" if {
    # 检测URL编码的引号 %22=" %27='
    regex.match(`%22|%27|%3B|%23`, input.request_raw_uri)
}
```

**启用授权配置**:

```yaml
# config.yaml
server:
  authorization: basic
```

**TLS配置**:

```yaml
# OPA配置
tls:
  cert_file: /certs/server-cert.pem
  private_key_file: /certs/server-key.pem
  ca_cert_file: /certs/ca-cert.pem
```

### 3.2 数据安全

- [ ] **敏感数据**: 敏感数据加密存储
- [ ] **访问控制**: 限制策略访问权限
- [ ] **审计日志**: 启用审计日志
- [ ] **数据备份**: 定期备份策略和数据
- [ ] **数据脱敏**: 日志中脱敏处理
- [ ] **合规检查**: 通过安全合规审计

**CVE-2025-46569审计日志配置**:

```yaml
# 启用决策日志记录可疑请求
decision_logs:
  console: false
  plugin: decision_logger
  reporting:
    max_decisions_per_second: 100
    upload_size_limit_bytes: 32768

# 记录所有Data API访问用于入侵检测
monitoring:
  enable_endpoint_metrics: true
  log_sensitive_paths: false
```

### 3.3 漏洞管理

- [ ] **镜像扫描**: 容器镜像无高危漏洞
- [ ] **依赖检查**: 依赖库无已知漏洞
- [ ] **定期更新**: 计划定期更新OPA版本
- [ ] **安全公告**: 订阅OPA安全公告
- [ ] **应急响应**: 准备安全应急预案
- [ ] **CVE-2025-46569修复验证**: 漏洞修复状态已确认

**CVE-2025-46569漏洞检测脚本**:

```bash
#!/bin/bash
# check-cve-2025-46569.sh - CVE-2025-46569漏洞检测脚本

set -e

echo "=== CVE-2025-46569 安全检测 ==="
echo "检测时间: $(date)"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0

# 1. 检查OPA版本
echo "[1/5] 检查OPA版本..."
OPA_VERSION=$(opa version 2>/dev/null | grep "Version:" | awk '{print $2}' || echo "unknown")

if [[ "$OPA_VERSION" == "unknown" ]]; then
    echo -e "${RED}✗ 无法检测OPA版本${NC}"
    FAILED=1
elif [[ "$OPA_VERSION" < "1.4.0" ]]; then
    echo -e "${RED}✗ 存在漏洞! 当前版本 $OPA_VERSION < 1.4.0${NC}"
    echo "  建议: 立即升级到 v1.4.0 或更高版本"
    FAILED=1
else
    echo -e "${GREEN}✓ 版本安全 (当前: $OPA_VERSION >= 1.4.0)${NC}"
fi

# 2. 检查授权策略配置
echo ""
echo "[2/5] 检查system.authz授权策略..."
AUTHZ_FILE=$(find . -name "authz.rego" -path "*/system/*" 2>/dev/null | head -1)

if [[ -z "$AUTHZ_FILE" ]]; then
    echo -e "${YELLOW}⚠ 未找到system.authz策略文件${NC}"
    echo "  建议: 创建 system/authz.rego 配置授权策略"
else
    echo -e "${GREEN}✓ 找到授权策略文件: $AUTHZ_FILE${NC}"
    
    # 检查是否包含路径验证
    if grep -q "valid_path_characters\|input.path" "$AUTHZ_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ 授权策略包含路径验证${NC}"
    else
        echo -e "${YELLOW}⚠ 授权策略可能缺少路径验证 (CVE-2025-46569防护)${NC}"
    fi
fi

# 3. 检查网络隔离
echo ""
echo "[3/5] 检查网络隔离配置..."
if kubectl get networkpolicy -l app=opa 2>/dev/null | grep -q "opa"; then
    echo -e "${GREEN}✓ 已配置NetworkPolicy${NC}"
else
    echo -e "${YELLOW}⚠ 未检测到NetworkPolicy配置${NC}"
    echo "  建议: 配置NetworkPolicy限制OPA网络访问"
fi

# 4. 检查API访问控制
echo ""
echo "[4/5] 检查API访问控制..."
if grep -r "authorization.*basic\|authorization.*token" . --include="*.yaml" --include="*.yml" 2>/dev/null | grep -q "authorization"; then
    echo -e "${GREEN}✓ 已配置API授权${NC}"
else
    echo -e "${YELLOW}⚠ 可能未启用API授权${NC}"
    echo "  建议: 在OPA配置中启用 authorization: basic"
fi

# 5. 检查监控告警
echo ""
echo "[5/5] 检查安全监控..."
if grep -r "CVE-2025-46569\|suspicious_request\|path.*injection" . --include="*.rego" 2>/dev/null | grep -q "."; then
    echo -e "${GREEN}✓ 已配置CVE-2025-46569监控规则${NC}"
else
    echo -e "${YELLOW}⚠ 未检测到CVE-2025-46569专用监控规则${NC}"
    echo "  建议: 添加可疑请求检测规则"
fi

echo ""
echo "=== 检测完成 ==="
if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}✓ 未发现高危问题${NC}"
    exit 0
else
    echo -e "${RED}✗ 发现高危安全问题，请立即修复!${NC}"
    exit 1
fi
```

---

## 4️⃣ 监控运维阶段

### 4.1 监控指标

- [ ] **性能监控**: P50/P95/P99延迟监控
- [ ] **错误监控**: 错误率监控
- [ ] **资源监控**: CPU/内存/网络监控
- [ ] **业务监控**: 决策分布监控
- [ ] **健康检查**: 配置liveness/readiness
- [ ] **SLO设置**: 定义服务等级目标

**关键指标**:

```promql
# P99延迟
histogram_quantile(0.99, rate(opa_http_request_duration_seconds_bucket[5m]))

# 错误率
rate(opa_http_request_errors_total[5m])

# 内存使用
container_memory_usage_bytes{container="opa"}

# 决策量
rate(opa_decision_total[5m])
```

### 4.2 日志管理

- [ ] **日志级别**: 生产环境使用info级别
- [ ] **结构化日志**: 使用JSON格式
- [ ] **日志收集**: 集成到日志系统
- [ ] **日志保留**: 设置合理保留期
- [ ] **审计日志**: 启用决策日志
- [ ] **日志分析**: 定期分析异常

**日志配置**:

```yaml
# OPA配置
decision_logs:
  console: false
  plugin: decision_logger
  reporting:
    max_decisions_per_second: 100
    upload_size_limit_bytes: 32768

# 只记录拒绝决策
decision_logs:
  console: true
  filter: |
    package system.log
    import rego.v1
    
    mask contains "/health"  # 忽略健康检查
    
    drop if {
        input.result.allow  # 忽略允许决策
    }
```

### 4.3 告警配置

- [ ] **延迟告警**: P99延迟超过阈值
- [ ] **错误告警**: 错误率超过阈值
- [ ] **资源告警**: CPU/内存超过80%
- [ ] **可用性告警**: 健康检查失败
- [ ] **Bundle告警**: Bundle加载失败
- [ ] **告警分级**: 区分critical/warning

**Prometheus告警规则**:

```yaml
groups:
  - name: opa
    rules:
      # 高延迟告警
      - alert: OPAHighLatency
        expr: histogram_quantile(0.99, rate(opa_http_request_duration_seconds_bucket[5m])) > 0.01
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "OPA P99延迟超过10ms"
          description: "当前P99: {{ $value }}s"
      
      # 高错误率告警
      - alert: OPAHighErrorRate
        expr: rate(opa_http_request_errors_total[5m]) / rate(opa_http_request_total[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "OPA错误率超过1%"
      
      # 内存告警
      - alert: OPAHighMemory
        expr: container_memory_usage_bytes{container="opa"} / container_spec_memory_limit_bytes{container="opa"} > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "OPA内存使用超过80%"
      
      # Bundle加载失败
      - alert: OPABundleLoadFailed
        expr: increase(opa_bundle_failed_load_counter[5m]) > 0
        labels:
          severity: critical
        annotations:
          summary: "OPA Bundle加载失败"
```

### 4.4 故障处理

- [ ] **降级方案**: 准备降级策略
- [ ] **回滚流程**: 快速回滚机制
- [ ] **应急文档**: 应急处理文档
- [ ] **值班制度**: 7x24值班安排
- [ ] **故障演练**: 定期故障演练
- [ ] **事后分析**: 故障后复盘

---

## 5️⃣ 文档合规阶段

### 5.1 技术文档

- [ ] **部署文档**: 完整的部署文档
- [ ] **运维手册**: 日常运维手册
- [ ] **故障手册**: 故障处理手册
- [ ] **API文档**: 策略API文档
- [ ] **架构图**: 部署架构图
- [ ] **配置说明**: 配置参数说明

### 5.2 变更管理

- [ ] **变更流程**: 遵循变更管理流程
- [ ] **影响分析**: 完成影响分析
- [ ] **审批记录**: 获得必要审批
- [ ] **通知机制**: 通知相关方
- [ ] **回退计划**: 准备回退计划
- [ ] **变更记录**: 记录变更历史

### 5.3 合规审计

- [ ] **合规要求**: 满足行业合规要求
- [ ] **审计日志**: 完整审计日志
- [ ] **访问控制**: 符合访问控制要求
- [ ] **数据保护**: 符合数据保护法规
- [ ] **审计报告**: 通过合规审计
- [ ] **持续合规**: 定期合规检查

---

## 6️⃣ 性能优化阶段

### 6.1 策略优化

- [ ] **部分求值**: 使用部分求值优化
- [ ] **索引优化**: 数据结构使用索引
- [ ] **缓存策略**: 合理使用缓存
- [ ] **规则简化**: 简化复杂规则
- [ ] **避免遍历**: 减少数组遍历
- [ ] **性能分析**: 使用profiling分析

**优化示例**:

```rego
# ❌ 性能差
permissions := [p | p := data.all_permissions[_]; p.user == input.user]

# ✅ 性能优化：使用索引
permissions := data.permissions_by_user[input.user]
```

### 6.2 部署优化

- [ ] **WASM编译**: 考虑WASM编译
- [ ] **Bundle优化**: 压缩Bundle体积
- [ ] **连接池**: 配置连接池
- [ ] **超时设置**: 合理的超时配置
- [ ] **资源调优**: 调优CPU/内存配置
- [ ] **网络优化**: 优化网络配置

### 6.3 性能目标

- [ ] **延迟目标**: P99延迟<预期值
- [ ] **吞吐目标**: QPS满足需求
- [ ] **资源目标**: CPU/内存在预算内
- [ ] **可用性目标**: 可用性≥99.9%
- [ ] **错误率目标**: 错误率<0.1%
- [ ] **容量规划**: 完成容量规划

**性能基准**:

| 场景 | P99延迟目标 | QPS目标 |
|------|-----------|---------|
| Sidecar | <5ms | 10K+ |
| 集中式 | <10ms | 50K+ |
| WASM | <2ms | 100K+ |

---

## 7️⃣ 灾难恢复阶段

### 7.1 备份策略

- [ ] **策略备份**: 定期备份策略代码
- [ ] **配置备份**: 备份配置文件
- [ ] **数据备份**: 备份决策数据
- [ ] **备份测试**: 定期测试恢复
- [ ] **异地备份**: 多地域备份
- [ ] **自动备份**: 自动化备份流程

### 7.2 容灾方案

- [ ] **多可用区**: 跨可用区部署
- [ ] **多区域**: 跨区域部署(可选)
- [ ] **故障转移**: 自动故障转移
- [ ] **数据同步**: 实时数据同步
- [ ] **容灾演练**: 定期容灾演练
- [ ] **RTO/RPO**: 明确RTO/RPO指标

### 7.3 降级预案

- [ ] **熔断机制**: 配置熔断策略
- [ ] **降级策略**: 准备降级方案
- [ ] **本地缓存**: 启用本地缓存降级
- [ ] **默认策略**: 准备默认策略
- [ ] **手动切换**: 支持手动降级
- [ ] **恢复机制**: 自动恢复机制
- [ ] **CVE-2025-46569应急响应**: 漏洞利用应急处置方案已准备

**CVE-2025-46569应急响应方案**:

```markdown
## CVE-2025-46569 应急响应流程

### 检测阶段
1. 监控可疑请求特征:
   - URL编码的引号 (%22, %27)
   - 异常路径深度 (>6层)
   - 访问system命名空间的尝试

2. 告警触发条件:
   - 短时间内大量Data API请求
   - 包含特殊字符的路径请求
   - 来自非信任源的请求

### 响应阶段
1. 立即措施:
   ```bash
   # 1. 启用紧急模式 (限制Data API访问)
   kubectl apply -f emergency-restrict-policy.yaml
   
   # 2. 增加OPA实例数量应对DoS
   kubectl scale deployment opa --replicas=10
   
   # 3. 启用WAF规则拦截恶意请求
   ```

2. 如果确认被利用:
   - 立即切换至离线模式
   - 启用默认允许/拒绝策略
   - 通知安全团队

### 恢复阶段
1. 升级OPA到v1.4.0+
2. 应用完整的system.authz策略
3. 验证所有防护机制
4. 恢复服务并持续监控
```

---

## ✅ 上线前最终检查

### 关键确认项

- [ ] **所有测试通过**: 单元/集成/性能测试全部通过
- [ ] **安全审计通过**: 安全团队审批
- [ ] **性能达标**: 性能指标符合要求
- [ ] **监控就绪**: 监控告警已配置
- [ ] **文档完整**: 所有文档已更新
- [ ] **团队培训**: 运维团队已培训
- [ ] **应急演练**: 完成应急演练
- [ ] **上线审批**: 获得上线审批

### CVE-2025-46569专项安全检查 🔒

- [ ] **安全漏洞扫描**: CVE-2025-46569漏洞检测通过
  - [ ] OPA版本 >= v1.4.0 已确认
  - [ ] 漏洞检测脚本执行通过
  - [ ] 无高危安全漏洞残留

- [ ] **网络隔离验证**: 网络层防护已生效
  - [ ] NetworkPolicy/防火墙规则已应用
  - [ ] OPA未直接暴露到公网
  - [ ] 仅允许白名单服务访问OPA端口
  - [ ] 网络连通性测试通过

- [ ] **API访问控制测试**: 授权策略功能验证
  - [ ] `system.authz` 策略已加载
  - [ ] 路径验证规则生效 (测试注入尝试被拒绝)
  - [ ] 管理员权限正常工作
  - [ ] 非法路径访问被正确拒绝
  - [ ] 健康检查端点可正常访问

**CVE-2025-46569验证命令**:

```bash
# 1. 版本验证
opa version | grep "Version:"

# 2. 授权策略验证
curl -s -o /dev/null -w "%{http_code}" \
  http://opa-server:8181/v1/data/app/users
# 期望返回: 200 (如果已认证) 或 401/403 (如果未授权)

# 3. 路径注入测试 (应当被拒绝)
curl -s -o /dev/null -w "%{http_code}" \
  "http://opa-server:8181/v1/data/app%2Fusers%22%20%23%20test"
# 期望返回: 403 (拒绝访问)

# 4. System命名空间访问测试 (应当被拒绝)
curl -s -o /dev/null -w "%{http_code}" \
  http://opa-server:8181/v1/data/system/authz/allow
# 期望返回: 403 (拒绝访问)

# 5. 深度路径限制测试
curl -s -o /dev/null -w "%{http_code}" \
  http://opa-server:8181/v1/data/a/b/c/d/e/f/g/h/i
# 期望返回: 403 (路径过深)
```

### 上线当天

- [ ] **备份现状**: 备份当前配置
- [ ] **通知相关方**: 通知利益相关方
- [ ] **灰度发布**: 采用灰度发布
- [ ] **实时监控**: 实时监控指标
- [ ] **值班到位**: 值班人员到位
- [ ] **回滚准备**: 回滚方案就绪
- [ ] **沟通渠道**: 沟通渠道畅通

### 上线后

- [ ] **监控观察**: 持续监控24小时
- [ ] **数据分析**: 分析上线数据
- [ ] **问题记录**: 记录遇到的问题
- [ ] **总结会议**: 上线总结会议
- [ ] **文档更新**: 更新相关文档
- [ ] **经验沉淀**: 沉淀经验教训

---

## 📊 检查清单评分

完成度计算：

```text
完成度 = (已勾选项 / 总检查项) × 100%

建议：
- ≥95%: 可以上线 ✅
- 85-95%: 补充遗漏项
- <85%: 暂缓上线 ❌
```

---

## 📝 检查记录模板

```markdown
# OPA生产环境检查记录

**项目名称**: _____________
**检查日期**: _____________
**检查人员**: _____________
**审核人员**: _____________

## 检查结果

- 总检查项: ___
- 已完成项: ___
- 未完成项: ___
- 完成度: ___%

## 关键发现

### 通过项
1. 
2. 

### 遗漏项
1. 
2. 

### 风险项
1. 
2. 

## 改进计划

| 项目 | 负责人 | 截止日期 | 状态 |
|------|-------|---------|------|
|      |       |         |      |

## 审批意见

- [ ] 同意上线
- [ ] 补充完善后上线
- [ ] 不同意上线

**签名**: _____________  
**日期**: _____________
```

---

## 🔗 相关资源

- [生产案例集](PRODUCTION_CASES.md)
- [性能优化指南](docs/08-最佳实践/08.2-性能优化指南.md)
- [安全合规标准](docs/01-技术规范/01.5-安全合规标准.md)
- [CVE-2025-46569安全通告](docs/12-理论实践/12.6-CVE-2025-46569安全通告.md)
- [FAQ](docs/FAQ.md)

---

## 🔒 附录A: CVE-2025-46569安全配置模板

### A.1 完整system.authz策略模板

```rego
# policy/system/authz.rego
# CVE-2025-46569防护授权策略

package system.authz

import rego.v1

# ========== 配置常量 ==========

# 允许的路径前缀 (白名单)
allowed_path_prefixes := {"public", "app", "api/v1", "api/v2"}

# 禁止访问的敏感命名空间
forbidden_namespaces := {"system", "debug", "internal"}

# 有效路径字符正则 (只允许字母、数字、下划线、斜杠)
valid_path_characters := `^[a-zA-Z0-9_]+$`

# 最大路径深度 (防御DoS)
max_path_depth := 6

# 管理员角色
admin_roles := {"admin", "security_admin"}

# ========== 默认拒绝 ==========

default allow := false

# ========== 健康检查 (无需认证) ==========

allow if {
    input.path == ["health"]
    input.method == "GET"
}

allow if {
    input.path == ["v1", "health"]
    input.method == "GET"
}

# ========== 标准Data API访问控制 ==========

allow if {
    # 基础HTTP方法检查
    input.method in ["GET", "POST"]
    
    # Data API端点
    input.path[0] == "v1"
    input.path[1] == "data"
    
    # 路径深度限制 (防御DoS)
    count(input.path) <= max_path_depth
    count(input.path) >= 3
    
    # 路径段验证 (防御路径注入)
    every segment in array.slice(input.path, 2, count(input.path)) {
        regex.match(valid_path_characters, segment)
    }
    
    # 前缀白名单检查
    input.path[2] in allowed_path_prefixes
    
    # 敏感命名空间保护
    not path_contains_forbidden_namespace
    
    # 请求体安全检查 (POST请求)
    safe_request_body
    
    # 身份认证检查
    valid_identity
}

# ========== 管理员特权访问 ==========

allow if {
    input.identity.role in admin_roles
    input.method in ["GET", "POST", "PUT", "DELETE"]
    input.path[0] == "v1"
    not suspicious_request
}

# ========== 辅助判断规则 ==========

# 检查路径是否包含敏感命名空间
path_contains_forbidden_namespace if {
    some ns in forbidden_namespaces
    ns in input.path
}

# 验证身份有效性
valid_identity if {
    input.identity
    input.identity.username
    input.identity.role
}

# 请求体安全检查
safe_request_body if {
    # GET请求无需检查body
    input.method == "GET"
}

safe_request_body if {
    input.method == "POST"
    # 检查请求体不包含可疑代码注入模式
    not regex.match(`["';#]`, sprintf("%v", [input.body]))
}

# 可疑请求检测 (CVE-2025-46569攻击特征)
suspicious_request if {
    # URL编码的引号
    regex.match(`%22|%27`, input.request_raw_uri)
}

suspicious_request if {
    # URL编码的分号或注释符
    regex.match(`%3B|%23|%2F%2F`, input.request_raw_uri)
}

suspicious_request if {
    # 路径深度异常
    count(input.path) > 10
}

suspicious_request if {
    # 包含特殊字符的路径段
    some segment in input.path
    regex.match(`["'<>;#]`, segment)
}

# ========== 拒绝原因 (用于审计日志) ==========

deny contains reason if {
    some reason in deny_reasons
}

deny_reasons contains "Invalid path characters detected" if {
    some segment in input.path
    regex.match(`["';%<>]`, segment)
}

deny_reasons contains "Path depth exceeds maximum allowed" if {
    count(input.path) > max_path_depth
}

deny_reasons contains "Access to forbidden namespace denied" if {
    path_contains_forbidden_namespace
    not input.identity.role in admin_roles
}

deny_reasons contains "Suspicious request pattern detected" if {
    suspicious_request
}

deny_reasons contains "Authentication required" if {
    not valid_identity
    input.path != ["health"]
    input.path != ["v1", "health"]
}

deny_reasons contains "Path prefix not in whitelist" if {
    input.path[0] == "v1"
    input.path[1] == "data"
    not input.path[2] in allowed_path_prefixes
}

# ========== 监控与审计 ==========

# 标记需要审计的请求
audit_log if {
    input.path[0] == "v1"
    input.path[1] == "data"
}

# 标记可疑请求
security_alert contains "CVE-2025-46569 exploit attempt detected" if {
    suspicious_request
    input.path[0] == "v1"
    input.path[1] == "data"
}
```

### A.2 入侵检测监控策略

```rego
# policy/security/monitoring.rego
# CVE-2025-46569入侵检测规则

package security.monitoring

import rego.v1

# ========== 可疑请求模式 ==========

# 检测CVE-2025-46569攻击尝试
suspicious_cve_2025_46569 if {
    # 检测URL编码的引号 (攻击payload特征)
    regex.match(`%22|%27|%60`, input.request_raw_uri)
    input.path[0] == "v1"
    input.path[1] == "data"
}

# 检测注释注入尝试
suspicious_cve_2025_46569 if {
    regex.match(`%23|%2F%2F|%2F\*`, input.request_raw_uri)
    input.path[0] == "v1"
    input.path[1] == "data"
}

# 检测分号注入
suspicious_cve_2025_46569 if {
    regex.match(`%3B`, input.request_raw_uri)
}

# 检测路径遍历
suspicious_cve_2025_46569 if {
    regex.match(`%2E%2E|%252E%252E`, input.request_raw_uri)
}

# 检测异常路径深度 (可能的DoS)
suspicious_cve_2025_46569 if {
    count(input.path) > 8
    input.path[0] == "v1"
    input.path[1] == "data"
}

# 检测对system命名空间的探测
suspicious_cve_2025_46569 if {
    "system" in input.path
    not input.identity.role == "admin"
}

# ========== 告警规则 ==========

# 高危告警: 疑似漏洞利用尝试
alert contains {
    "severity": "critical",
    "type": "cve-2025-46569-exploit-attempt",
    "message": "疑似CVE-2025-46569漏洞利用尝试",
    "client_ip": input.remote_addr,
    "request_path": input.request_raw_uri,
    "timestamp": input.timestamp
} if {
    suspicious_cve_2025_46569
}

# 中危告警: 异常Data API访问模式
alert contains {
    "severity": "warning", 
    "type": "unusual-data-api-access",
    "message": "异常的Data API访问模式",
    "client_ip": input.remote_addr,
    "request_path": input.path,
    "timestamp": input.timestamp
} if {
    # 访问不存在的路径
    input.path[0] == "v1"
    input.path[1] == "data"
    count(input.path) > 5
    not suspicious_cve_2025_46569
}

# 统计型告警: 高频访问
high_frequency_access if {
    # 实际实现需要结合外部数据源统计
    # 这里定义规则框架
    input.path[0] == "v1"
    input.path[1] == "data"
    input.request_rate_per_minute > 1000
}
```

### A.3 Kubernetes安全配置清单

```yaml
# CVE-2025-46569 Kubernetes安全配置

# 1. NetworkPolicy - 网络隔离
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opa-cve-2025-46569-protection
  namespace: opa
spec:
  podSelector:
    matchLabels:
      app: opa
  policyTypes:
  - Ingress
  - Egress
  ingress:
  # 只允许来自API Gateway的访问
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    - podSelector:
        matchLabels:
          app: api-gateway
    ports:
    - protocol: TCP
      port: 8181
  # 允许来自监控系统的访问
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    ports:
    - protocol: TCP
      port: 8181
  egress:
  # 只允许访问必要的后端服务
  - to:
    - namespaceSelector:
        matchLabels:
          name: bundle-server
    ports:
    - protocol: TCP
      port: 443

---
# 2. PodSecurityPolicy / SecurityContext
apiVersion: v1
kind: Pod
metadata:
  name: opa-secure
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: opa
    image: openpolicyagent/opa:1.4.0
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "500m"
    livenessProbe:
      httpGet:
        path: /health
        port: 8181
      initialDelaySeconds: 10
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?ready=1
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 5

---
# 3. ResourceQuota - 防止DoS
apiVersion: v1
kind: ResourceQuota
metadata:
  name: opa-quota
  namespace: opa
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "5"
    limits.memory: 5Gi

---
# 4. LimitRange - 默认资源限制
apiVersion: v1
kind: LimitRange
metadata:
  name: opa-limits
  namespace: opa
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    type: Container
```

### A.4 API网关路径过滤配置

```nginx
# nginx/opapath_filter.conf
# Nginx路径过滤配置 - CVE-2025-46569防护

upstream opa_backend {
    server opa-service.opa.svc.cluster.local:8181;
    keepalive 32;
}

server {
    listen 80;
    server_name opa-gateway.example.com;
    
    # 安全请求头
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    
    # 日志格式
    log_format security '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $body_bytes_sent '
                       '"$http_referer" "$http_user_agent" '
                       'req_time=$request_time '
                       'suspicious=$suspicious_request';
    
    access_log /var/log/nginx/opa-access.log security;
    
    # ========== 安全路径过滤 ==========
    
    # 只允许安全的字符出现在路径中
    location ~* ^/v1/data/[a-zA-Z0-9_]+(/[a-zA-Z0-9_]+)*$ {
        # 检查可疑字符
        if ($request_uri ~* ["'%<>;#]) {
            return 403 "Invalid characters in path";
        }
        
        # 检查URL编码的特殊字符
        if ($request_uri ~* %22|%27|%3C|%3E|%3B|%23) {
            return 403 "Encoded special characters detected";
        }
        
        # 代理到OPA
        proxy_pass http://opa_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 超时设置
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
    
    # 拒绝其他Data API路径
    location /v1/data/ {
        return 403 "Path does not match allowed pattern";
    }
    
    # 其他API端点 (健康检查等)
    location /health {
        proxy_pass http://opa_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
    
    location /v1/health {
        proxy_pass http://opa_backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
    
    # 默认拒绝
    location / {
        return 403 "Access denied";
    }
}
```

### A.5 快速检查清单 (打印版)

```markdown
## CVE-2025-46569 部署前快速检查清单

### 版本检查 ⬜
- [ ] OPA版本 >= v1.4.0
- [ ] 执行: `opa version | grep Version`

### 授权策略检查 ⬜
- [ ] system/authz.rego 已创建
- [ ] 路径验证规则已配置
- [ ] 敏感命名空间(system)已保护
- [ ] 路径深度限制已设置 (建议<=6)

### 网络防护检查 ⬜
- [ ] NetworkPolicy已应用
- [ ] OPA未暴露公网IP
- [ ] 仅允许白名单服务访问

### API访问控制检查 ⬜
- [ ] 身份认证已启用
- [ ] 测试: 合法请求返回200
- [ ] 测试: 非法路径返回403
- [ ] 测试: system访问返回403

### 监控告警检查 ⬜
- [ ] 可疑请求检测规则已配置
- [ ] 告警通道已测试
- [ ] 日志收集已启用

### 应急响应检查 ⬜
- [ ] 应急联系人名单已更新
- [ ] 升级回滚流程已准备
- [ ] 演练记录已存档
```

---

## 📞 获取帮助

遇到问题？

- 📖 查看文档: [docs/](docs/)
- 💬 提问讨论: [GitHub Discussions](../../discussions)
- 🐛 报告问题: [GitHub Issues](../../issues)

---

**版本**: v1.0  
**维护**: OPA中文文档团队  
**更新**: 每季度review并更新
