package rbac

import rego.v1

# 默认拒绝所有请求（Default Deny）
default allow := false

# 获取用户角色的所有权限
user_permissions contains permission if {
	some permission in data.roles[input.user.role].permissions
}

# 允许请求，当用户有相应权限
allow if {
	input.action in user_permissions
}

# 获取拒绝原因（用于审计和调试）
deny_reason := reason if {
	not allow
	reason := sprintf("User role '%s' does not have permission for action '%s'", [
		input.user.role,
		input.action,
	])
}

