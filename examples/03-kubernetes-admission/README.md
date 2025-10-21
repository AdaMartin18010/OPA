# 示例03：Kubernetes准入控制

> **难度**: ⭐⭐⭐ 中级  
> **场景**: Kubernetes资源验证  
> **学习时间**: 30-45分钟

---

## 📋 场景说明

实现Kubernetes准入控制策略，验证Pod资源配置：
- ✅ 强制要求资源限制（CPU/内存）
- ✅ 强制镜像来自可信仓库
- ✅ 禁止特权容器
- ✅ 要求资源标签（app、env、owner）

### 应用场景

- **生产环境**：防止资源滥用和安全风险
- **多租户集群**：确保资源公平分配
- **合规要求**：满足安全基线

---

## 📁 文件说明

- `policy.rego`: K8s准入策略
- `policy_test.rego`: 完整测试套件
- `input_valid_pod.json`: 符合规范的Pod
- `input_invalid_pod.json`: 违规Pod（测试拒绝）
- `input_privileged_pod.json`: 特权Pod（应拒绝）

---

## 🚀 快速运行

### 1. 测试所有场景

```bash
cd examples/03-kubernetes-admission
opa test . -v
```

预期输出：
```
data.kubernetes.admission.test_valid_pod_allowed: PASS
data.kubernetes.admission.test_missing_resources_denied: PASS
data.kubernetes.admission.test_privileged_container_denied: PASS
data.kubernetes.admission.test_untrusted_image_denied: PASS
data.kubernetes.admission.test_missing_labels_denied: PASS
--------------------------------------------------------------------------------
PASS: 12/12
```

### 2. 验证合规Pod

```bash
opa eval -i input_valid_pod.json -d policy.rego "data.kubernetes.admission.deny" --format pretty
```

预期输出（空数组 = 通过）：
```
[]
```

### 3. 验证违规Pod

```bash
opa eval -i input_invalid_pod.json -d policy.rego "data.kubernetes.admission.deny" --format pretty
```

预期输出（包含拒绝原因）：
```json
[
  "Container 'nginx' must specify CPU limits",
  "Container 'nginx' must specify memory limits",
  "Pod must have label 'app'",
  "Pod must have label 'env'"
]
```

---

## 📖 核心概念

### 1. Kubernetes AdmissionReview结构

```rego
# input是Kubernetes发送的AdmissionReview对象
# 结构：
{
  "request": {
    "kind": {"kind": "Pod"},
    "object": {
      "metadata": {...},
      "spec": {...}
    }
  }
}
```

### 2. 拒绝规则（Deny Rules）

```rego
# 生成拒绝原因集合
deny contains msg if {
    # 条件：某个容器没有资源限制
    some container in input.request.object.spec.containers
    not container.resources.limits.cpu
    msg := sprintf("Container '%s' must specify CPU limits", [container.name])
}
```

**关键**：使用`contains`定义集合，每个规则产生一个拒绝原因。

### 3. 辅助函数

```rego
# 获取Pod对象（简化访问）
pod := input.request.object

# 获取所有容器（包括init容器）
all_containers := array.concat(
    pod.spec.containers,
    object.get(pod.spec, "initContainers", [])
)
```

---

## 🎓 学习要点

### 1. 遍历容器

```rego
deny contains msg if {
    some container in all_containers
    # 检查每个容器...
}
```

使用`some ... in ...`遍历数组，Rego会为每个元素生成规则。

### 2. 镜像仓库验证

```rego
deny contains msg if {
    some container in all_containers
    image := container.image
    not startswith(image, "registry.example.com/")
    not startswith(image, "docker.io/library/")
    msg := sprintf("Container '%s' image must be from trusted registry", [container.name])
}
```

**提示**：使用`startswith`检查镜像前缀。

### 3. 必需标签检查

```rego
required_labels := ["app", "env", "owner"]

deny contains msg if {
    some label in required_labels
    not pod.metadata.labels[label]
    msg := sprintf("Pod must have label '%s'", [label])
}
```

**技巧**：定义必需标签列表，遍历检查。

### 4. 特权容器检查

```rego
deny contains msg if {
    some container in all_containers
    container.securityContext.privileged == true
    msg := sprintf("Container '%s' cannot run in privileged mode", [container.name])
}
```

---

## 🔧 扩展练习

### 练习1：镜像标签验证

禁止使用`latest`标签，要求明确版本号。

**提示**：
```rego
deny contains msg if {
    some container in all_containers
    endswith(container.image, ":latest")
    # ...
}
```

### 练习2：资源配额检查

限制单个容器资源上限（如CPU不超过4核）。

**提示**：
```rego
import rego.v1

max_cpu_cores := 4

deny contains msg if {
    some container in all_containers
    cpu_limit := parse_cpu(container.resources.limits.cpu)
    cpu_limit > max_cpu_cores
    # ...
}

parse_cpu(cpu_string) := cores if {
    # 实现CPU字符串解析（如"2000m" -> 2）
    # ...
}
```

### 练习3：命名空间策略

不同命名空间应用不同策略（如`prod`命名空间要求更严格）。

**提示**：
```rego
is_prod_namespace if {
    input.request.namespace == "prod"
}

deny contains msg if {
    is_prod_namespace
    # 生产环境特有检查...
}
```

---

## 🚀 Gatekeeper集成

### 转换为ConstraintTemplate

```yaml
apiVersion: templates.gatekeeper.sh/v1
kind: ConstraintTemplate
metadata:
  name: k8spodrequirements
spec:
  crd:
    spec:
      names:
        kind: K8sPodRequirements
      validation:
        openAPIV3Schema:
          type: object
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package kubernetes.admission
        # ... 粘贴policy.rego内容 ...
```

### 创建Constraint

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sPodRequirements
metadata:
  name: pod-requirements
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    trustedRegistries:
      - "registry.example.com/"
      - "docker.io/library/"
```

---

## 📚 相关文档

- [Kubernetes集成](../../docs/04-生态系统/04.1-Kubernetes集成.md)
- [Gatekeeper详解](../../docs/04-生态系统/04.2-Gatekeeper详解.md)
- [生产案例：金融K8s策略](../../docs/09-生产实战/09.2-金融K8s策略实战.md)（待创建）

---

## ❓ 常见问题

**Q: 如何在真实集群测试？**

A: 方法1（本地测试）：
```bash
# 获取现有Pod的AdmissionReview格式
kubectl get pod <pod-name> -o json | \
  jq '{request: {object: .}}' > test_input.json
opa eval -i test_input.json -d policy.rego "data.kubernetes.admission.deny"
```

方法2（Gatekeeper Audit）：
```bash
# 部署为ConstraintTemplate和Constraint
# 使用audit模式，不会拒绝资源，只记录违规
kubectl get constraint k8spodrequirements -o yaml
```

**Q: 性能影响？**

A: Gatekeeper webhook通常增加50-100ms延迟。优化建议：
- 使用简单的规则
- 避免复杂的循环和递归
- 参考[性能优化指南](../../docs/08-最佳实践/08.2-性能优化指南.md)

**Q: 如何处理例外？**

A: 使用Constraint的`match.excludedNamespaces`或自定义豁免逻辑：
```rego
# 豁免系统命名空间
is_exempt_namespace if {
    input.request.namespace in ["kube-system", "kube-public"]
}

deny contains msg if {
    not is_exempt_namespace
    # ... 检查逻辑 ...
}
```

---

**下一步**: 学习 [示例04：性能优化](../04-performance-optimization/README.md)

