package kubernetes.admission

import rego.v1

# Pod对象快捷方式
pod := input.request.object

# 所有容器（包括init容器）
all_containers := array.concat(
	object.get(pod.spec, "containers", []),
	object.get(pod.spec, "initContainers", []),
)

# 可信镜像仓库列表
trusted_registries := [
	"registry.example.com/",
	"docker.io/library/",
	"gcr.io/",
	"quay.io/",
]

# 必需的Pod标签
required_labels := ["app", "env", "owner"]

# ====================
# 资源限制检查
# ====================

deny contains msg if {
	some container in all_containers
	not container.resources.limits.cpu
	msg := sprintf("Container '%s' must specify CPU limits", [container.name])
}

deny contains msg if {
	some container in all_containers
	not container.resources.limits.memory
	msg := sprintf("Container '%s' must specify memory limits", [container.name])
}

deny contains msg if {
	some container in all_containers
	not container.resources.requests.cpu
	msg := sprintf("Container '%s' must specify CPU requests", [container.name])
}

deny contains msg if {
	some container in all_containers
	not container.resources.requests.memory
	msg := sprintf("Container '%s' must specify memory requests", [container.name])
}

# ====================
# 镜像仓库检查
# ====================

deny contains msg if {
	some container in all_containers
	image := container.image
	not image_from_trusted_registry(image)
	msg := sprintf("Container '%s' image '%s' must be from trusted registry", [
		container.name,
		image,
	])
}

image_from_trusted_registry(image) if {
	some registry in trusted_registries
	startswith(image, registry)
}

# ====================
# 安全上下文检查
# ====================

deny contains msg if {
	some container in all_containers
	container.securityContext.privileged == true
	msg := sprintf("Container '%s' cannot run in privileged mode", [container.name])
}

deny contains msg if {
	some container in all_containers
	container.securityContext.runAsUser == 0
	msg := sprintf("Container '%s' cannot run as root (UID 0)", [container.name])
}

deny contains msg if {
	some container in all_containers
	container.securityContext.allowPrivilegeEscalation == true
	msg := sprintf("Container '%s' cannot allow privilege escalation", [container.name])
}

# ====================
# 标签检查
# ====================

deny contains msg if {
	some label in required_labels
	not pod.metadata.labels[label]
	msg := sprintf("Pod must have label '%s'", [label])
}

# ====================
# 命名规范检查
# ====================

deny contains msg if {
	not regex.match("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", pod.metadata.name)
	msg := "Pod name must be lowercase alphanumeric with hyphens"
}

# ====================
# Host配置检查
# ====================

deny contains msg if {
	pod.spec.hostNetwork == true
	msg := "Pod cannot use host network"
}

deny contains msg if {
	pod.spec.hostPID == true
	msg := "Pod cannot use host PID namespace"
}

deny contains msg if {
	pod.spec.hostIPC == true
	msg := "Pod cannot use host IPC namespace"
}

