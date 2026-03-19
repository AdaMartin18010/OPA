# OPA/Rego 版本兼容性说明

> **最后更新**: 2026-03-19  
> **文档版本**: v1.2  
> **验证周期**: 每月检查并更新

---

## 🚨 重要安全公告

### CVE-2025-46569 - HTTP Data API 路径注入漏洞

**严重程度**: 🔴 HIGH  
**影响版本**: OPA < v1.4.0  
**修复版本**: OPA v1.4.0+  
**发布日期**: 2025-05

**漏洞描述**:  
OPA 的 HTTP Data API 存在路径注入漏洞，攻击者可通过构造特殊的 URL 路径参数访问或修改未经授权的数据。

**影响**:  
- 使用 `--set` 或环境变量配置的数据可能被泄露
- 多租户场景下的数据隔离可能被绕过
- 通过 Data API 的未经授权数据访问

**解决方案**:  
```bash
# 立即升级到安全版本
docker pull openpolicyagent/opa:1.4.0
# 或
brew upgrade opa
```

---

## 📋 快速参考

| 本项目文档适用版本 | OPA版本 | Rego语言版本 | 测试状态 |
|-------------------|---------|-------------|---------|
| **当前推荐** | **v1.4+** | **v1.0** | ✅ 已验证 |
| **安全最低要求** | **v1.4+** | **v1.0** | ⚠️ 必需（CVE修复） |
| 兼容版本 | v0.68+ | v1.0 | ✅ 兼容 |
| 最低要求 | v0.55+ | v1.0 | ⚠️ 建议升级 |
| 测试覆盖 | v0.55 - v1.4 | v1.0 | ✅ 全面 |

---

## 🎯 核心版本信息

### OPA版本

**最新稳定版**: v1.4.0 (2025-05)  
**安全最低版**: v1.4.0 (2025-05) - 修复 CVE-2025-46569  
**上一稳定版**: v0.68.0 (2024-10)  
**最低支持版**: v0.55.0 (2023-08)  
**Rego v1冻结**: v0.42.0 (2022-06) 引入Rego v1

### Rego语言版本

**当前版本**: v1.0  
**状态**: ✅ 语法已冻结（自2022年6月）  
**语法**: 使用 `import rego.v1` 启用  
**OPA v1.0+ 强制要求**: `if` 和 `contains` 关键字必须显式使用

---

## 📊 功能兼容性矩阵

### 核心语言特性

| 特性 | 最低OPA版本 | Rego版本 | 本文档使用 | 说明 |
|------|------------|---------|-----------|------|
| 基础语法 | v0.1+ | - | ✅ | package, import, rules |
| `if` 关键字 | v0.42+ | v1.0 | ✅ | 替代 `:-`，v1.0+ 强制要求 |
| `contains` 关键字 | v0.42+ | v1.0 | ✅ | 集合规则，v1.0+ 强制要求 |
| `in` 关键字 | v0.42+ | v1.0 | ✅ | 成员测试 |
| `every` 关键字 | v0.42+ | v1.0 | ✅ | 全称量词 |
| `import rego.v1` | v0.42+ | v1.0 | ✅ | 启用v1语法 |

### OPA v1.x 新特性

| 特性 | 版本 | 说明 |
|------|------|------|
| 默认 localhost 绑定 | v1.0+ | 默认仅监听 localhost 接口，更安全 |
| 强制 v1 语法 | v1.0+ | Rego v1 语法强制启用 |
| 改进的性能 | v1.0+ | 查询评估速度提升 20-30% |
| 新的 CLI 输出格式 | v1.0+ | 更友好的错误和日志输出 |

### 编译和部署

| 特性 | 最低OPA版本 | 测试状态 | 本文档覆盖 |
|------|------------|---------|-----------|
| WASM编译 | v0.20+ | ✅ | [01.3-WASM编译规范](docs/01-技术规范/01.3-WASM编译规范.md) |
| Bundle打包 | v0.10+ | ✅ | [01.2-Bundle格式规范](docs/01-技术规范/01.2-Bundle格式规范.md) |
| 部分求值 | v0.20+ | ✅ | [03.6-部分求值技术](docs/03-实现架构/03.6-部分求值技术.md) |
| IR优化 | v0.50+ | ✅ | [03.3-编译器设计](docs/03-实现架构/03.3-编译器设计.md) |

### 内置函数

| 函数类别 | 最低OPA版本 | 函数数量 | 文档链接 |
|---------|------------|---------|---------|
| 字符串操作 | v0.1+ | 20+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#字符串函数) |
| 数组操作 | v0.1+ | 15+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#数组函数) |
| 对象操作 | v0.1+ | 10+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#对象函数) |
| 集合操作 | v0.1+ | 10+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#集合函数) |
| JWT | v0.10+ | 5+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#jwt函数) |
| 加密 | v0.20+ | 8+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#加密函数) |
| HTTP | v0.30+ | 2+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#http函数) |
| GraphQL | v0.45+ | 5+ | [02.3-内置函数库](docs/02-语言模型/02.3-内置函数库.md#图遍历) |

### 生态系统集成

| 工具/平台 | 版本要求 | 测试版本 | 兼容性 | 文档 |
|---------|---------|---------|-------|------|
| **Kubernetes** | 1.23+ | 1.28, 1.29, 1.30, 1.31 | ✅ | [04.1-Kubernetes集成](docs/04-生态系统/04.1-Kubernetes集成.md) |
| **Gatekeeper** | v3.10+ | v3.17, v3.18 | ✅ | [04.2-Gatekeeper详解](docs/04-生态系统/04.2-Gatekeeper详解.md) |
| **Envoy** | 1.18+ | 1.31, 1.32 | ✅ | [05.2-API网关授权](docs/05-应用场景/05.2-API网关授权.md) |
| **Istio** | 1.10+ | 1.23, 1.24 | ✅ | [05.2-API网关授权](docs/05-应用场景/05.2-API网关授权.md) |
| **Docker** | 20.10+ | 27.x, 28.x | ✅ | 部署示例 |

---

## 🔄 重要版本变更历史

### OPA v1.4.0 (2025-05) - 安全修复版本

**安全修复**:

- 🔒 **CVE-2025-46569 修复**: HTTP Data API 路径注入漏洞
- 影响范围: OPA < v1.4.0 的所有版本
- 建议所有用户立即升级

**新特性**:

- 性能优化：查询评估速度提升 20-30%
- 改进错误消息和调试信息
- 新的内置函数增强
- CLI 输出格式改进

**破坏性变更**:

- 默认仅绑定 localhost 接口（需显式配置 `--addr` 允许远程访问）
- Rego v1 语法强制要求使用 `if` 和 `contains` 关键字

**影响**: 本文档所有示例已验证兼容 v1.4.0

---

### OPA v1.0.0 (2025-01) - 主要版本发布

**新特性**:

- 🎉 OPA 正式达到 v1.0 里程碑
- 默认 localhost 绑定，增强安全性
- Rego v1 语法成为默认和强制标准
- 性能显著提升

**破坏性变更**:

```rego
# v0.x 兼容写法（不再支持）
allow {
    input.user == "admin"
}

# v1.x 强制写法
allow if {
    input.user == "admin"
}

# 或
allow contains user if {
    input.user == user
}
```

---

### OPA v0.68.0 (2024-10)

**新特性**:

- 性能优化：查询评估速度提升15%
- 新增内置函数：`crypto.x509.parse_and_verify_certificates_with_options`
- 改进WASM编译器

**影响**: 本文档所有示例已验证兼容

---

### OPA v0.60.0 (2024-02)

**新特性**:

- 新增 `http.send` 超时配置
- 改进部分求值性能
- WASM内存优化

**影响**: 部分求值相关文档已更新

---

### OPA v0.55.0 (2023-08)

**新特性**:

- 稳定的Rego v1语法
- 改进错误消息
- 性能基准工具增强

**影响**: 本文档最低支持版本

**⚠️ 重要**: v0.55之前的版本可能与文档示例不兼容

---

### OPA v0.42.0 (2022-06) - Rego v1里程碑

**新特性**:

- 🎉 引入Rego v1语法
- 新关键字：`if`, `contains`, `in`, `every`
- `import rego.v1` 启用新语法

**影响**: **所有文档使用Rego v1语法**

**迁移指南**:

```rego
# Rego v0 (旧语法)
allow = true {
    input.user == "admin"
}

# Rego v1 (新语法 - 本文档使用)
import rego.v1

allow if {
    input.user == "admin"
}
```

---

## 📖 按文档的版本要求

### 技术规范

| 文档 | 最低OPA版本 | 推荐版本 | 关键特性 |
|------|------------|---------|---------|
| [01.1-API规范](docs/01-技术规范/01.1-API规范.md) | v0.10+ | v1.4+ | REST API, Health Check |
| [01.2-Bundle格式](docs/01-技术规范/01.2-Bundle格式规范.md) | v0.10+ | v1.4+ | Bundle签名需v0.20+ |
| [01.3-WASM编译](docs/01-技术规范/01.3-WASM编译规范.md) | v0.20+ | v1.4+ | 优化需v0.50+ |
| [01.4-性能基准](docs/01-技术规范/01.4-性能基准与度量.md) | v0.30+ | v1.4+ | Profiling工具 |
| [01.5-安全合规](docs/01-技术规范/01.5-安全合规标准.md) | v0.30+ | v1.4+ | TLS, 签名验证, CVE修复 |

### 语言模型

| 文档 | 最低OPA版本 | 推荐版本 | Rego版本 |
|------|------------|---------|---------|
| [02.1-Rego语法](docs/02-语言模型/02.1-Rego语法规范.md) | v0.42+ | v1.4+ | v1.0 必需 |
| [02.2-类型系统](docs/02-语言模型/02.2-类型系统.md) | v0.42+ | v1.4+ | v1.0 |
| [02.3-内置函数](docs/02-语言模型/02.3-内置函数库.md) | v0.30+ | v1.4+ | 部分函数有版本要求 |
| [02.4-求值模型](docs/02-语言模型/02.4-求值模型.md) | v0.42+ | v1.4+ | v1.0 |

### 实现架构

| 文档 | 最低OPA版本 | 推荐版本 | 说明 |
|------|------------|---------|------|
| [03.1-词法解析](docs/03-实现架构/03.1-词法分析与语法解析.md) | v0.42+ | v1.4+ | Rego v1解析器 |
| [03.2-AST与IR](docs/03-实现架构/03.2-AST与IR.md) | v0.50+ | v1.4+ | 新IR引入v0.50 |
| [03.3-编译器设计](docs/03-实现架构/03.3-编译器设计.md) | v0.50+ | v1.4+ | 优化Pass |
| [03.4-求值器](docs/03-实现架构/03.4-Top-Down求值器.md) | v0.42+ | v1.4+ | - |
| [03.5-索引优化](docs/03-实现架构/03.5-索引与优化.md) | v0.30+ | v1.4+ | - |
| [03.6-部分求值](docs/03-实现架构/03.6-部分求值技术.md) | v0.20+ | v1.4+ | 性能关键 |

---

## ⚠️ 已知兼容性问题

### 1. Rego v0 vs v1

**问题**: 混用v0和v1语法

**症状**:

```text
rego_parse_error: unexpected keyword, must use 'if' keyword
```

**解决**:

```rego
# 方案1: 使用Rego v1 (推荐)
import rego.v1

allow if {
    input.user == "admin"
}

# 方案2: 使用旧语法（仅v0.x）
allow = true {
    input.user == "admin"
}
```

---

### 2. OPA v1.x 默认 localhost 绑定

**问题**: 升级后 OPA 无法从远程访问

**症状**:

```text
curl: (7) Failed to connect to <host> port 8181: Connection refused
```

**原因**: OPA v1.0+ 默认只绑定 localhost 接口以增强安全性

**解决**:

```bash
# 允许所有接口访问（开发环境）
opa run --server --addr :8181

# 允许特定接口访问（生产环境）
opa run --server --addr 192.168.1.100:8181

# Docker 部署
docker run -p 8181:8181 openpolicyagent/opa:1.4.0 run --server --addr :8181
```

---

### 3. WASM编译限制

**问题**: 部分内置函数不支持WASM

**不支持的函数**:

- `http.send` (网络I/O)
- `opa.runtime` (运行时信息)

**解决**: 使用SDK注入外部数据

---

### 4. Kubernetes版本

**问题**: K8s API变化

**影响**: AdmissionReview API版本

**解决**:

```rego
# 支持多版本
admission.v1
admission.v1beta1
```

---

## 🔍 版本检查命令

### 检查OPA版本

```bash
opa version

# 输出:
# Version: 1.4.0
# Build Commit: ...
# Build Timestamp: ...
# Build Hostname: ...
```

### 检查Rego语法版本

```bash
# 验证v1语法
opa check --strict --format pretty policy.rego

# 转换v0到v1
opa fmt -w --rego-v1 policy.rego
```

### 测试兼容性

```bash
# 使用特定OPA版本测试
docker run --rm -v $(pwd):/work openpolicyagent/opa:1.4.0 test /work

# 测试多个版本
for version in 0.68.0 1.0.0 1.4.0; do
  echo "Testing OPA $version..."
  docker run --rm -v $(pwd):/work openpolicyagent/opa:$version test /work
done
```

---

## 🆘 升级指南

### 从 v0.x 升级到 v1.x

#### 步骤 1: 评估当前版本

```bash
# 检查当前版本
opa version

# 评估现有策略兼容性
opa check --strict *.rego
```

#### 步骤 2: 备份现有配置

```bash
# 备份策略文件
cp -r policies/ policies-backup-$(date +%Y%m%d)/

# 备份 OPA 配置
cp config.yaml config.yaml.backup
```

#### 步骤 3: 更新 Rego 语法

```bash
# 自动转换 v0 语法到 v1 语法
opa fmt -w --rego-v1 *.rego

# 验证转换结果
opa check --strict *.rego
```

#### 步骤 4: 手动修复强制要求

```rego
# 转换前的 v0 语法（需要更新）
allow {
    input.user == "admin"
}

# 转换后的 v1 语法（正确）
import rego.v1

allow if {
    input.user == "admin"
}

# 集合规则转换示例
# v0
admins["alice"]

# v1
admins contains "alice"
```

#### 步骤 5: 更新网络绑定配置

```bash
# v0.x 默认行为（绑定所有接口）
opa run --server

# v1.x 需要显式配置（推荐用于生产）
opa run --server --addr 0.0.0.0:8181

# 或使用配置文件
cat > config.yaml <<EOF
services:
  - name: local
    url: http://localhost:8080
labels:
  environment: production
EOF

opa run --server --config-file config.yaml --addr 0.0.0.0:8181
```

#### 步骤 6: 运行全面测试

```bash
# 运行所有测试
opa test . -v

# 使用新版本验证
opa test --bundle bundle.tar.gz -v
```

#### 步骤 7: 更新部署配置

```yaml
# Kubernetes 部署示例更新
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opa
spec:
  template:
    spec:
      containers:
        - name: opa
          image: openpolicyagent/opa:1.4.0  # 更新镜像版本
          args:
            - "run"
            - "--server"
            - "--addr=0.0.0.0:8181"  # 显式绑定所有接口
            - "--config-file=/config/config.yaml"
```

#### 步骤 8: 验证 CVE-2025-46569 修复

```bash
# 确认运行安全版本
docker run --rm openpolicyagent/opa:1.4.0 version
# 应显示: Version: 1.4.0
```

---

### 从 v0.4x 升级到 v0.68+

```bash
# 1. 转换为Rego v1语法
opa fmt -w --rego-v1 *.rego

# 2. 添加import
echo "import rego.v1" > temp.rego
cat policy.rego >> temp.rego
mv temp.rego policy.rego

# 3. 运行测试
opa test . -v

# 4. 更新部署配置
# - 更新Docker镜像版本
# - 更新Kubernetes部署YAML
```

---

## 📅 维护计划

### 检查周期

- **每月**: 检查OPA新版本发布
- **每季度**: 更新兼容性矩阵
- **重大版本**: 立即评估影响
- **安全公告**: 24小时内响应

### 更新流程

1. ✅ 检查OPA发布说明
2. ✅ 测试新版本与文档示例
3. ✅ 更新兼容性矩阵
4. ✅ 更新受影响文档
5. ✅ 更新CI/CD版本
6. ✅ 验证安全修复

---

## 📞 获取帮助

遇到版本兼容性问题？

- 📖 查看 [FAQ](docs/FAQ.md#版本兼容性)
- 💬 提问 [GitHub Discussions](../../discussions)
- 🐛 报告 [GitHub Issues](../../issues)
- 📧 邮件 [维护者](mailto:maintainer@example.com)
- 🔒 安全漏洞报告: security@openpolicyagent.org

---

## 🔗 相关资源

- [OPA发布说明](https://github.com/open-policy-agent/opa/releases)
- [Rego v1迁移指南](https://www.openpolicyagent.org/docs/latest/rego-v1-migration/)
- [OPA v1.0 升级指南](https://www.openpolicyagent.org/docs/latest/v1.0-upgrade/)
- [兼容性测试](https://github.com/open-policy-agent/opa/tree/main/test)
- [CVE-2025-46569 公告](https://github.com/open-policy-agent/opa/security/advisories)

---

**最后更新**: 2026-03-19  
**下次检查**: 2026-04-19  
**维护者**: OPA中文文档团队
