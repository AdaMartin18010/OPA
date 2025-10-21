package kubernetes.admission

import rego.v1

# ====================
# 合规Pod测试
# ====================

valid_pod := {
	"request": {"object": {
		"metadata": {
			"name": "valid-pod",
			"labels": {
				"app": "myapp",
				"env": "prod",
				"owner": "team-a",
			},
		},
		"spec": {"containers": [{
			"name": "nginx",
			"image": "docker.io/library/nginx:1.21",
			"resources": {
				"requests": {
					"cpu": "100m",
					"memory": "128Mi",
				},
				"limits": {
					"cpu": "200m",
					"memory": "256Mi",
				},
			},
			"securityContext": {
				"runAsUser": 1000,
				"allowPrivilegeEscalation": false,
			},
		}]},
	}},
}

test_valid_pod_allowed if {
	count(deny) == 0 with input as valid_pod
}

# ====================
# 资源限制测试
# ====================

test_missing_cpu_limits_denied if {
	pod_without_cpu_limits := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/spec/containers/0/resources/limits/cpu",
	}])

	violations := deny with input as pod_without_cpu_limits
	count(violations) > 0
	some violation in violations
	contains(violation, "CPU limits")
}

test_missing_memory_limits_denied if {
	pod_without_memory_limits := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/spec/containers/0/resources/limits/memory",
	}])

	violations := deny with input as pod_without_memory_limits
	count(violations) > 0
}

test_missing_cpu_requests_denied if {
	pod_without_cpu_requests := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/spec/containers/0/resources/requests/cpu",
	}])

	violations := deny with input as pod_without_cpu_requests
	count(violations) > 0
}

# ====================
# 镜像仓库测试
# ====================

test_untrusted_image_denied if {
	pod_with_untrusted_image := json.patch(valid_pod, [{
		"op": "replace",
		"path": "/request/object/spec/containers/0/image",
		"value": "hacker.com/malicious:latest",
	}])

	violations := deny with input as pod_with_untrusted_image
	count(violations) > 0
	some violation in violations
	contains(violation, "trusted registry")
}

test_trusted_image_allowed if {
	registries := [
		"docker.io/library/nginx:1.21",
		"gcr.io/my-project/app:v1",
		"quay.io/prometheus/prometheus:v2.30.0",
		"registry.example.com/myapp:latest",
	]

	every registry in registries {
		pod_with_registry := json.patch(valid_pod, [{
			"op": "replace",
			"path": "/request/object/spec/containers/0/image",
			"value": registry,
		}])

		# 只检查镜像相关的违规（可能有其他违规）
		violations := {v | some v in deny with input as pod_with_registry}
		not any_image_violation(violations)
	}
}

any_image_violation(violations) if {
	some v in violations
	contains(v, "trusted registry")
}

# ====================
# 安全上下文测试
# ====================

test_privileged_container_denied if {
	pod_with_privileged := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/containers/0/securityContext/privileged",
		"value": true,
	}])

	violations := deny with input as pod_with_privileged
	count(violations) > 0
	some violation in violations
	contains(violation, "privileged mode")
}

test_root_user_denied if {
	pod_with_root := json.patch(valid_pod, [{
		"op": "replace",
		"path": "/request/object/spec/containers/0/securityContext/runAsUser",
		"value": 0,
	}])

	violations := deny with input as pod_with_root
	count(violations) > 0
	some violation in violations
	contains(violation, "root")
}

test_privilege_escalation_denied if {
	pod_with_escalation := json.patch(valid_pod, [{
		"op": "replace",
		"path": "/request/object/spec/containers/0/securityContext/allowPrivilegeEscalation",
		"value": true,
	}])

	violations := deny with input as pod_with_escalation
	count(violations) > 0
	some violation in violations
	contains(violation, "privilege escalation")
}

# ====================
# 标签测试
# ====================

test_missing_app_label_denied if {
	pod_without_app_label := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/metadata/labels/app",
	}])

	violations := deny with input as pod_without_app_label
	count(violations) > 0
	some violation in violations
	contains(violation, "label 'app'")
}

test_missing_env_label_denied if {
	pod_without_env_label := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/metadata/labels/env",
	}])

	violations := deny with input as pod_without_env_label
	count(violations) > 0
}

test_missing_owner_label_denied if {
	pod_without_owner_label := json.patch(valid_pod, [{
		"op": "remove",
		"path": "/request/object/metadata/labels/owner",
	}])

	violations := deny with input as pod_without_owner_label
	count(violations) > 0
}

# ====================
# Host配置测试
# ====================

test_host_network_denied if {
	pod_with_host_network := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/hostNetwork",
		"value": true,
	}])

	violations := deny with input as pod_with_host_network
	count(violations) > 0
	some violation in violations
	contains(violation, "host network")
}

test_host_pid_denied if {
	pod_with_host_pid := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/hostPID",
		"value": true,
	}])

	violations := deny with input as pod_with_host_pid
	count(violations) > 0
}

test_host_ipc_denied if {
	pod_with_host_ipc := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/hostIPC",
		"value": true,
	}])

	violations := deny with input as pod_with_host_ipc
	count(violations) > 0
}

# ====================
# Init容器测试
# ====================

test_init_containers_validated if {
	pod_with_init := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/initContainers",
		"value": [{
			"name": "init",
			"image": "docker.io/library/busybox:1.34",
			"resources": {
				"requests": {
					"cpu": "50m",
					"memory": "64Mi",
				},
				"limits": {
					"cpu": "100m",
					"memory": "128Mi",
				},
			},
			"securityContext": {
				"runAsUser": 1000,
				"allowPrivilegeEscalation": false,
			},
		}],
	}])

	# 应该通过
	count(deny) == 0 with input as pod_with_init
}

test_init_container_missing_resources_denied if {
	pod_with_bad_init := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/initContainers",
		"value": [{
			"name": "bad-init",
			"image": "docker.io/library/busybox:1.34",
			"securityContext": {
				"runAsUser": 1000,
				"allowPrivilegeEscalation": false,
			},
		}],
	}])

	violations := deny with input as pod_with_bad_init
	count(violations) > 0
	# 应该有4个违规（CPU/内存 requests/limits）
	count(violations) >= 4
}

# ====================
# 多容器测试
# ====================

test_all_containers_validated if {
	pod_with_multiple := json.patch(valid_pod, [{
		"op": "add",
		"path": "/request/object/spec/containers/-",
		"value": {
			"name": "sidecar",
			"image": "docker.io/library/alpine:3.14",
			"resources": {
				"requests": {
					"cpu": "10m",
					"memory": "32Mi",
				},
				"limits": {
					"cpu": "50m",
					"memory": "64Mi",
				},
			},
			"securityContext": {
				"runAsUser": 1001,
				"allowPrivilegeEscalation": false,
			},
		},
	}])

	# 两个容器都应该通过
	count(deny) == 0 with input as pod_with_multiple
}

