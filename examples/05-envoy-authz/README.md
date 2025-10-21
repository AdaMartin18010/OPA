# Envoy集成示例：API网关授权

> **难度**: ⭐⭐⭐⭐ 高级  
> **学习时间**: 60-90分钟  
> **场景**: API网关授权，Envoy External Authorization  
> **前置知识**: RBAC、JWT、Envoy基础

---

## 📖 场景说明

本示例展示如何将OPA集成到Envoy作为**External Authorization服务**，实现API网关的细粒度授权控制。

### 典型应用场景

- **微服务API网关**: 统一的授权入口
- **零信任架构**: 每个请求都需要授权
- **多租户SaaS**: 基于租户的访问控制
- **边缘计算**: 在网络边界进行授权

---

## 🏗️ 架构设计

```text
┌─────────┐    HTTP请求     ┌────────┐   gRPC Check   ┌─────┐
│ Client  │ ───────────────>│ Envoy  │ ──────────────>│ OPA │
│         │                 │ Proxy  │                │     │
└─────────┘                 └────────┘                └─────┘
                                │                        │
                                │ 授权决策 (allow/deny)  │
                                │<───────────────────────┘
                                │
                                ▼
                          ┌──────────┐
                          │ Backend  │
                          │ Service  │
                          └──────────┘
```

### 决策流程

1. **客户端请求** → Envoy监听端口
2. **Envoy拦截** → 调用OPA External Authorization
3. **OPA评估**:
   - 提取JWT token
   - 验证签名和过期时间
   - 检查角色权限
   - 检查API路径权限
4. **返回决策**:
   - `allow = true` → 转发请求
   - `allow = false` → 返回403 Forbidden

---

## 📦 文件清单

```bash
05-envoy-authz/
├── README.md                    # 本文档
├── policy.rego                  # OPA授权策略
├── policy_test.rego             # 单元测试
├── envoy.yaml                   # Envoy配置
├── opa-config.yaml              # OPA配置
├── jwt_secret.json              # JWT密钥（示例）
├── docker-compose.yml           # Docker编排
├── input_valid.json             # 有效请求示例
├── input_invalid.json           # 无效请求示例
└── test.sh                      # 集成测试脚本
```

---

## 🚀 快速开始

### 前置条件

```bash
# 需要安装：
- Docker & Docker Compose
- OPA CLI (用于本地测试)
- curl (用于发送测试请求)
```

### 1. 启动服务

```bash
# 启动 Envoy + OPA + Backend
docker-compose up -d

# 查看服务状态
docker-compose ps
```

服务端口：

- **Envoy**: `http://localhost:8000` (API Gateway)
- **OPA**: `http://localhost:8181` (Authorization Service)
- **Backend**: `http://localhost:8080` (后端服务)

### 2. 生成测试Token

```bash
# Admin用户token
export ADMIN_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsInJvbGUiOiJhZG1pbiIsImV4cCI6OTk5OTk5OTk5OX0.xxx"

# User用户token
export USER_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJ1c2VyIiwiZXhwIjo5OTk5OTk5OTk5fQ.yyy"
```

### 3. 测试授权

```bash
# ✅ Admin访问管理接口 - 应该成功
curl -H "Authorization: Bearer $ADMIN_TOKEN" \
  http://localhost:8000/api/admin/users

# ✅ User访问用户接口 - 应该成功
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:8000/api/users/profile

# ❌ User访问管理接口 - 应该被拒绝
curl -H "Authorization: Bearer $USER_TOKEN" \
  http://localhost:8000/api/admin/users

# ❌ 无Token访问 - 应该被拒绝
curl http://localhost:8000/api/users/profile
```

### 4. 运行单元测试

```bash
cd examples/05-envoy-authz
opa test . -v

# 预期输出：
# ✅ 25/25 tests passed
```

---

## 📝 策略详解

### 核心策略逻辑

```rego
package envoy.authz

import rego.v1

# 默认拒绝
default allow := false

# 主决策规则
allow if {
    # 1. Token有效
    valid_token
    
    # 2. Token未过期
    not_expired
    
    # 3. 有权限访问该路径
    has_permission
}

# Token验证
valid_token if {
    token := extract_token
    io.jwt.verify_hs256(token, input.jwt_secret)
}

# 过期检查
not_expired if {
    token := extract_token
    [_, payload, _] := io.jwt.decode(token)
    now := time.now_ns() / 1000000000
    payload.exp > now
}

# 权限检查
has_permission if {
    role := get_role
    path := input.attributes.request.http.path
    method := input.attributes.request.http.method
    
    # 从权限表中查找
    permissions[role][path][_] == method
}
```

### 权限矩阵

| 角色 | 路径模式 | 允许的HTTP方法 |
|---|---|---|
| **admin** | `/api/admin/*` | GET, POST, PUT, DELETE |
| **admin** | `/api/users/*` | GET, POST, PUT, DELETE |
| **user** | `/api/users/profile` | GET, PUT |
| **user** | `/api/users/settings` | GET, PUT |
| **guest** | `/api/public/*` | GET |

---

## 🧪 测试用例

### 测试1：Admin全权限

```rego
test_admin_can_access_admin_api if {
    allow with input as {
        "attributes": {
            "request": {
                "http": {
                    "method": "GET",
                    "path": "/api/admin/users",
                    "headers": {
                        "authorization": "Bearer <valid-admin-token>"
                    }
                }
            }
        },
        "jwt_secret": "test-secret"
    }
}
```

### 测试2：User受限权限

```rego
test_user_cannot_access_admin_api if {
    not allow with input as {
        "attributes": {
            "request": {
                "http": {
                    "method": "GET",
                    "path": "/api/admin/users",
                    "headers": {
                        "authorization": "Bearer <valid-user-token>"
                    }
                }
            }
        },
        "jwt_secret": "test-secret"
    }
}
```

### 测试3：Token过期

```rego
test_expired_token_denied if {
    not allow with input as {
        "attributes": {
            "request": {
                "http": {
                    "headers": {
                        "authorization": "Bearer <expired-token>"
                    }
                }
            }
        },
        "jwt_secret": "test-secret"
    }
}
```

---

## ⚙️ 配置文件

### Envoy配置 (envoy.yaml)

```yaml
static_resources:
  listeners:
  - name: main
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 8000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          codec_type: AUTO
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: backend
              domains: ["*"]
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: backend_service
          http_filters:
          # OPA External Authorization
          - name: envoy.filters.http.ext_authz
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.ext_authz.v3.ExtAuthz
              transport_api_version: V3
              grpc_service:
                envoy_grpc:
                  cluster_name: opa_service
                timeout: 1s
              with_request_body:
                max_request_bytes: 8192
                allow_partial_message: true
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router

  clusters:
  - name: backend_service
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: backend_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: backend
                port_value: 8080
  
  - name: opa_service
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    load_assignment:
      cluster_name: opa_service
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: opa
                port_value: 9191
```

### OPA配置 (opa-config.yaml)

```yaml
plugins:
  envoy_ext_authz_grpc:
    addr: :9191
    path: envoy/authz/allow
    dry-run: false
    enable-reflection: true

decision_logs:
  console: true

bundles:
  authz:
    resource: /bundles/bundle.tar.gz
    polling:
      min_delay_seconds: 10
      max_delay_seconds: 20
```

---

## 🐳 Docker Compose

```yaml
version: '3.8'

services:
  # Envoy代理
  envoy:
    image: envoyproxy/envoy:v1.28-latest
    ports:
      - "8000:8000"   # API Gateway
      - "9901:9901"   # Admin interface
    volumes:
      - ./envoy.yaml:/etc/envoy/envoy.yaml
    command: ["-c", "/etc/envoy/envoy.yaml", "-l", "info"]
    depends_on:
      - opa
      - backend
  
  # OPA授权服务
  opa:
    image: openpolicyagent/opa:latest-envoy
    ports:
      - "8181:8181"   # REST API
      - "9191:9191"   # gRPC
    volumes:
      - ./policy.rego:/policies/policy.rego
      - ./jwt_secret.json:/secrets/jwt_secret.json
      - ./opa-config.yaml:/config/config.yaml
    command:
      - "run"
      - "--server"
      - "--config-file=/config/config.yaml"
      - "/policies"
  
  # 后端服务 (示例)
  backend:
    image: hashicorp/http-echo
    ports:
      - "8080:8080"
    command:
      - "-text=Hello from backend service!"
      - "-listen=:8080"
```

---

## 📊 性能考虑

### 延迟影响

| 组件 | 延迟 | 说明 |
|---|---|---|
| **无OPA** | ~1ms | 直接转发 |
| **带OPA** | ~5-15ms | 增加授权检查 |
| **JWT验证** | ~2-5ms | Token解析和验证 |
| **总延迟** | ~10-20ms | P99延迟 |

### 优化建议

1. **Token缓存**: 缓存已验证的token (有效期内)
2. **决策缓存**: OPA内置缓存机制
3. **连接池**: Envoy与OPA之间使用HTTP/2
4. **并行处理**: 多OPA实例负载均衡

---

## 🔧 故障排查

### 问题1：403 Forbidden

**检查**:

```bash
# 1. Token是否有效
echo $ADMIN_TOKEN | cut -d'.' -f2 | base64 -d | jq

# 2. OPA决策日志
docker logs opa-envoy-authz-opa-1

# 3. Envoy日志
docker logs opa-envoy-authz-envoy-1
```

### 问题2：Connection Refused

**检查服务状态**:

```bash
# 所有服务是否运行
docker-compose ps

# 网络连通性
docker exec -it envoy ping opa
```

### 问题3：Token过期

**生成新Token**:

```bash
# 使用jwt.io或本地工具生成
# Header: {"alg": "HS256", "typ": "JWT"}
# Payload: {"sub": "admin", "role": "admin", "exp": 9999999999}
# Secret: "test-secret"
```

---

## 📚 扩展练习

### 练习1：添加速率限制

在策略中添加每个用户的请求速率限制：

```rego
# 每个用户每分钟最多100个请求
rate_limit if {
    user_id := get_user_id
    count := rate_limiter[user_id].count
    count < 100
}
```

### 练习2：基于IP的访问控制

添加IP白名单/黑名单：

```rego
# 允许的IP范围
allowed_ips := {"192.168.1.0/24", "10.0.0.0/8"}

# IP检查
valid_ip if {
    client_ip := input.attributes.source.address.socketAddress.address
    net.cidr_contains(allowed_ips[_], client_ip)
}
```

### 练习3：动态权限加载

从外部数据源加载权限配置：

```rego
# 从Bundle加载权限
permissions := data.permissions

# 从HTTP API加载
permissions := http.send({
    "method": "GET",
    "url": "http://permissions-api/roles"
}).body
```

---

## 🎯 生产部署建议

### 1. 高可用配置

```yaml
# 多OPA实例
opa:
  replicas: 3
  resources:
    requests:
      cpu: "500m"
      memory: "256Mi"
    limits:
      cpu: "1000m"
      memory: "512Mi"
```

### 2. 监控指标

```prometheus
# Envoy指标
envoy_http_ext_authz_allowed
envoy_http_ext_authz_denied
envoy_http_ext_authz_duration_ms

# OPA指标
opa_http_request_duration_seconds
opa_policy_evaluation_duration_ns
```

### 3. 日志审计

```yaml
# OPA决策日志
decision_logs:
  plugin: my_decision_logger
  reporting:
    min_delay_seconds: 60
    max_delay_seconds: 120
```

---

## 🔗 相关资源

- [Envoy External Authorization](https://www.envoyproxy.io/docs/envoy/latest/configuration/http/http_filters/ext_authz_filter)
- [OPA Envoy Plugin](https://www.openpolicyagent.org/docs/latest/envoy-introduction/)
- [JWT验证](https://www.openpolicyagent.org/docs/latest/policy-reference/#jwt)
- [API网关授权文档](../../docs/05-应用场景/05.2-API网关授权.md)

---

## 📝 总结

本示例展示了：

✅ **Envoy + OPA集成**: External Authorization架构  
✅ **JWT验证**: Token解析、签名验证、过期检查  
✅ **RBAC授权**: 基于角色的API访问控制  
✅ **完整配置**: Docker Compose一键部署  
✅ **生产就绪**: 高可用、监控、审计

**关键收获**:

- 理解零信任架构在API网关的应用
- 掌握OPA gRPC协议集成
- 学习JWT Token验证最佳实践
- 了解Envoy External Authorization工作原理

---

**下一步**: 尝试[数据过滤示例](../06-data-filtering/)，学习行级权限控制！
