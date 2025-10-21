# OPA版本: v0.55+
# Rego版本: v1.0
# 测试状态: ✅ 已验证
# 最后测试: 2025-10-21

package example.hello

import rego.v1

# 默认拒绝
default allow := false

# 基础规则：允许admin用户
allow if {
	input.user.role == "admin"
}

# 允许资源所有者访问
allow if {
	input.user.id == input.resource.owner
}

# 欢迎消息
greeting := msg if {
	allow
	msg := sprintf("Hello, %s! Welcome to OPA.", [input.user.name])
}

greeting := "Access Denied" if {
	not allow
}

