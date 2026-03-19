# OPA技术文档项目 - API参考

> **适用版本**: v2.6.0
> **最后更新**: 2026年3月19日

---

## 🚀 项目API接口

本项目提供以下自动化接口和工具：

### Makefile API

#### 构建相关

| 命令 | 描述 | 示例 |
|------|------|------|
| `make help` | 显示帮助信息 | `make help` |
| `make install` | 安装依赖 | `make install` |
| `make build` | 构建文档站点 | `make build` |
| `make dev` | 启动开发服务器 | `make dev` |
| `make clean` | 清理构建产物 | `make clean` |

#### 测试相关

| 命令 | 描述 | 示例 |
|------|------|------|
| `make test` | 运行所有测试 | `make test` |
| `make test-examples` | 测试代码示例 | `make test-examples` |
| `make lint` | 检查代码规范 | `make lint` |
| `make lint-fix` | 自动修复格式 | `make lint-fix` |
| `make verify` | 验证项目完整性 | `make verify` |

#### 部署相关

| 命令 | 描述 | 示例 |
|------|------|------|
| `make deploy` | 部署到GitHub Pages | `make deploy` |
| `make benchmark` | 运行性能测试 | `make benchmark` |
| `make stats` | 显示项目统计 | `make stats` |

#### 安全相关

| 命令 | 描述 | 示例 |
|------|------|------|
| `make security-check` | 运行安全检查 | `make security-check` |
| `make update-opa` | 更新OPA版本 | `make update-opa` |

### Docker API

#### 容器操作

```bash
# 构建镜像
docker build -t opa-docs .

# 运行文档站点
docker run -p 8080:80 opa-docs

# 使用Docker Compose
docker-compose up -d

# 开发环境
docker-compose up dev

# OPA服务
docker-compose up opa
```

### 脚本API

#### run-all-tests.sh

```bash
# 运行完整测试套件
./scripts/run-all-tests.sh

# 输出: 测试报告和覆盖率
```

**返回状态**:

- `0` - 所有测试通过
- `1` - 部分测试失败

#### verify-project.sh

```bash
# 验证项目完整性
./scripts/verify-project.sh

# 检查项:
# - 文档完整性
# - 代码格式
# - 版本信息
# - 安全状态
```

#### security-check.sh

```bash
# 安全检查
./scripts/security-check.sh

# 检查内容:
# - OPA版本
# - CVE-2025-46569状态
# - 安全文档存在性
```

---

## 📦 文档结构API

### 文档访问路径

```
/docs
├── 00-总览与索引.md              # 入口文档
├── 01-技术规范/                   # 技术规范章节
│   ├── 01.1-API规范.md
│   ├── 01.2-Bundle格式规范.md
│   ├── 01.3-WASM编译规范.md
│   ├── 01.4-性能基准与度量.md
│   └── 01.5-安全合规标准.md
├── 02-语言模型/                   # 语言模型章节
│   ├── 02.1-Rego语法规范.md
│   ├── 02.2-类型系统.md
│   ├── 02.3-内置函数库.md
│   └── 02.4-求值模型.md
└── ...                           # 其他章节
```

### 示例访问路径

```
/examples
├── 01-hello-world/               # 入门示例
├── 02-basic-rbac/                # RBAC示例
├── 03-kubernetes-admission/      # K8s示例
├── 04-performance-optimization/  # 性能示例
├── 05-envoy-authz/               # Envoy示例
└── 06-data-filtering/            # 数据过滤示例
```

---

## 🔧 配置API

### VuePress配置

```javascript
// docs/.vuepress/config.js
module.exports = {
  title: 'OPA 技术文档',
  description: 'Open Policy Agent 全面技术分析',
  base: '/OPA/',

  themeConfig: {
    nav: [...],        // 导航配置
    sidebar: {...},    // 侧边栏配置
    search: true       // 搜索配置
  },

  plugins: [...]       // 插件配置
}
```

### Docker Compose配置

```yaml
# docker-compose.yml
version: '3.8'
services:
  docs:
    build: .
    ports:
      - "8080:80"

  opa:
    image: openpolicyagent/opa:1.4.0
    ports:
      - "8181:8181"
```

---

## 📊 数据API

### 项目统计接口

```bash
# 获取项目统计
make stats

# 输出:
# 文档统计:
#   核心文档: 61 篇
#   根目录文档: 45 篇
# 代码统计:
#   示例项目: 6 个
#   Rego文件: 50+ 个
```

### 测试报告接口

```bash
# 生成测试报告
make test 2>&1 | tee test-report.txt

# 报告包含:
# - 测试通过率
# - 失败详情
# - 覆盖率统计
```

---

## 🔒 安全API

### 漏洞检查

```bash
# 检查CVE-2025-46569
make security-check

# 手动检查OPA版本
opa version | grep "Version:"

# 应返回: Version: 1.4.0 或更高
```

### 安全加固

```bash
# 查看安全文档
cat docs/12-理论实践/12.6-CVE-2025-46569安全通告.md

# 查看检查清单
cat CHECKLIST.md | grep -A 10 "安全"
```

---

## 🌐 在线API

### GitHub API集成

```bash
# 获取最新Release
curl -s https://api.github.com/repos/AdaMartin18010/OPA/releases/latest

# 获取仓库统计
curl -s https://api.github.com/repos/AdaMartin18010/OPA

# 获取贡献者列表
curl -s https://api.github.com/repos/AdaMartin18010/OPA/contributors
```

### OPA API

```bash
# 查询策略 (本地OPA服务)
curl -X POST http://localhost:8181/v1/data/example/allow \
  -H "Content-Type: application/json" \
  -d '{"input": {"user": {"role": "admin"}}}'

# 上传策略
curl -X PUT http://localhost:8181/v1/policies/example \
  -H "Content-Type: text/plain" \
  --data-binary @policy.rego
```

---

## 📖 使用示例

### 完整工作流

```bash
# 1. 克隆项目
git clone https://github.com/AdaMartin18010/OPA.git
cd OPA

# 2. 初始化
make setup

# 3. 验证
make verify

# 4. 测试
make test

# 5. 开发
make dev

# 6. 构建
make build

# 7. 部署
make deploy
```

### CI/CD集成

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup
        run: make setup
      - name: Test
        run: make test
      - name: Verify
        run: make verify
      - name: Build
        run: make build
```

---

## 📝 API版本控制

### 版本历史

| 版本 | 日期 | API变更 |
|------|------|---------|
| v2.6.0 | 2026-03-19 | 新增security-check API |
| v2.5.0 | 2025-10-25 | 新增Docker支持 |
| v2.4.0 | 2025-10-21 | 新增CI/CD API |
| v2.0.0 | 2025-10-18 | 初始API定义 |

### 兼容性

- 所有API向后兼容
- 废弃API保留至少2个版本
- 破坏性变更在主要版本更新

---

## 🆘 错误处理

### 错误代码

| 代码 | 含义 | 解决方案 |
|------|------|----------|
| `0` | 成功 | - |
| `1` | 一般错误 | 查看日志 |
| `2` | 测试失败 | 运行make test查看详情 |
| `3` | 构建失败 | 检查依赖 |
| `127` | 命令不存在 | 安装必要工具 |

### 调试模式

```bash
# 启用调试输出
DEBUG=1 make test

# 详细日志
make test VERBOSE=1
```

---

**API版本**: v2.6.0
**最后更新**: 2026年3月19日
**维护者**: OPA中文文档团队

📖 **[查看完整文档](docs/)** | 🔧 **[查看工具](scripts/)** | 🚀 **[快速开始](README.md)**
