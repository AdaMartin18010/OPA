# OPA技术文档项目 - 性能监控指南

> **适用版本**: v2.6.0
> **最后更新**: 2026年3月19日

---

## 📊 监控概述

本文档介绍如何监控OPA技术文档项目的性能指标，包括文档构建、站点运行和代码示例。

---

## 🎯 监控维度

### 1. 文档构建性能

#### 监控指标

| 指标 | 目标值 | 告警阈值 |
|------|--------|----------|
| 构建时间 | < 60秒 | > 120秒 |
| 内存使用 | < 2GB | > 4GB |
| 构建成功率 | > 99% | < 95% |

#### 监控命令

```bash
# 测量构建时间
time make build

# 监控内存使用
/usr/bin/time -v make build 2>&1 | grep "Maximum resident"

# 使用Make内置统计
make stats
```

### 2. 站点运行性能

#### 监控指标

| 指标 | 目标值 | 告警阈值 |
|------|--------|----------|
| 首屏加载时间 | < 2秒 | > 5秒 |
| 页面完全加载 | < 5秒 | > 10秒 |
| Time to Interactive | < 3秒 | > 8秒 |
| Lighthouse评分 | > 90 | < 70 |

#### 监控工具

```bash
# 使用Lighthouse
npm install -g lighthouse
lighthouse https://adamartin18010.github.io/OPA/ --output=html

# 使用PageSpeed Insights
# https://pagespeed.web.dev/
```

### 3. 代码示例性能

#### 监控指标

| 指标 | 目标值 | 告警阈值 |
|------|--------|----------|
| 测试执行时间 | < 10秒 | > 30秒 |
| 测试通过率 | 100% | < 95% |
| 策略评估延迟 | < 1ms | > 10ms |

#### 监控命令

```bash
# 运行性能测试
make benchmark

# 监控OPA评估性能
cd examples/04-performance-optimization
./benchmark.sh
```

---

## 🛠️ 监控工具

### 内置监控脚本

#### 1. 项目统计 (make stats)

```bash
$ make stats

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  项目统计
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
文档统计:
  核心文档: 61 篇
  根目录文档: 48 篇
  总字数: 390K+

代码统计:
  示例项目: 6 个
  Rego文件: 50+ 个
  测试文件: 30+ 个

版本信息:
  项目版本: v2.6.0
  OPA版本: 1.4.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 2. 项目验证 (make verify)

```bash
$ make verify

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  全面项目验证
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
通过: 45
失败: 0

✅ 项目验证通过 - 100% 完成
```

#### 3. 性能基准测试 (make benchmark)

```bash
$ make benchmark

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  OPA性能基准测试
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OPA版本: 1.4.0

测试: policy_fast.rego
  平均延迟: 0.5ms
  吞吐量: 2000 ops/s

测试: policy_slow.rego
  平均延迟: 5ms
  吞吐量: 200 ops/s

✅ 性能测试完成
```

### 外部监控工具

#### Google Analytics 4

```javascript
// docs/.vuepress/config.js
head: [
  ['script', { async: true, src: 'https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX' }],
  ['script', {}, `
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-XXXXXXXXXX');
  `]
]
```

#### GitHub Insights

```
访问: https://github.com/AdaMartin18010/OPA/graphs/traffic

查看:
- 访问量
- 克隆统计
- 引用来源
```

---

## 📈 性能基准

### 构建性能基准

| 操作 | 基准值 | 优秀 | 需优化 |
|------|--------|------|--------|
| npm install | 30s | < 20s | > 60s |
| make build | 45s | < 30s | > 90s |
| make test | 15s | < 10s | > 30s |
| make verify | 10s | < 5s | > 20s |

### 站点性能基准

| 指标 | 基准值 | 优秀 | 需优化 |
|------|--------|------|--------|
| First Contentful Paint | 1.5s | < 1s | > 3s |
| Largest Contentful Paint | 2.5s | < 2s | > 4s |
| Time to Interactive | 3.5s | < 3s | > 6s |
| Cumulative Layout Shift | 0.1 | < 0.05 | > 0.25 |

---

## 🚨 告警配置

### GitHub Actions告警

```yaml
# .github/workflows/monitor.yml
name: Performance Monitor
on:
  schedule:
    - cron: '0 0 * * *'  # 每天运行

jobs:
  monitor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Run benchmarks
        run: make benchmark > benchmark.log

      - name: Check performance regression
        run: |
          if grep -q "TOO_SLOW" benchmark.log; then
            echo "::error::Performance regression detected!"
            exit 1
          fi
```

### 邮件告警

```bash
#!/bin/bash
# scripts/performance-alert.sh

THRESHOLD=10000  # 10秒

START_TIME=$(date +%s%N)
make build
END_TIME=$(date +%s%N)

DURATION=$(( (END_TIME - START_TIME) / 1000000 ))  # 转换为毫秒

if [ $DURATION -gt $THRESHOLD ]; then
    echo "Build time $DURATION ms exceeds threshold $THRESHOLD ms" | \
    mail -s "Performance Alert" admin@example.com
fi
```

---

## 📊 性能报告

### 周报模板

```markdown
# 性能周报 (2026-03-19)

## 构建性能
- 平均构建时间: 42s (↓ 5s)
- 成功率: 100%
- 内存使用: 1.2GB

## 站点性能
- 首屏加载: 1.2s (目标: < 2s) ✅
- Lighthouse评分: 95 (↑ 3)
- Core Web Vitals: 全部通过 ✅

## 代码示例
- 测试通过率: 100%
- 平均执行时间: 8s
- 策略评估延迟: 0.8ms

## 问题与改进
- 无重大问题
- 建议: 优化图片加载
```

### 性能趋势图

```
构建时间趋势 (过去30天):

时间 (秒)
60 |                    ╱
50 |                 ╱
40 |    ╱‾‾‾‾‾‾‾‾‾‾‾      ← 优化后
30 |   ╱
20 |  ╱
10 | ╱
 0 +───────────────────────
   Week1  Week2  Week3  Week4
```

---

## 🔧 性能优化

### 构建优化

```bash
# 1. 使用缓存
npm ci --cache .npm

# 2. 增量构建
# VuePress默认支持

# 3. 并行处理
export NODE_OPTIONS="--max-old-space-size=4096"
```

### 站点优化

```javascript
// docs/.vuepress/config.js
module.exports = {
  // 图片懒加载
  markdown: {
    image: {
      lazyLoading: true
    }
  },

  // 代码分割
  bundlerConfig: {
    splitChunks: {
      chunks: 'all'
    }
  }
}
```

### 代码优化

```rego
# 使用索引优化
allow if {
    data.users[input.user.id].role == "admin"
}

# 避免重复计算
allowed_users := {u | u := data.users[_]; u.role == "admin"}
```

---

## 📚 相关文档

- [08.2-性能优化指南](docs/08-最佳实践/08.2-性能优化指南.md)
- [12.2-性能剖析实战](docs/12-理论实践/12.2-性能剖析实战.md)
- [ARCHITECTURE.md](ARCHITECTURE.md) - 架构设计
- [API.md](API.md) - API参考

---

## 📞 获取帮助

性能问题？请联系我们：

- 🐛 [提交Issue](../../issues/new?labels=performance)
- 💬 [参与讨论](../../discussions)

---

**性能监控指南维护**: OPA中文文档团队
**最后更新**: 2026年3月19日
**版本**: v2.6.0

📊 **[查看仪表板](DASHBOARD.md)** | 🔧 **[故障排除](TROUBLESHOOTING.md)** | 🏠 **[返回首页](README.md)**
