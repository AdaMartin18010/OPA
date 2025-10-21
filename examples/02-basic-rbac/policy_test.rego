package rbac

import rego.v1

# 测试数据：角色权限配置
test_roles := {
	"admin": {"permissions": ["read", "write", "delete", "admin"]},
	"editor": {"permissions": ["read", "write"]},
	"viewer": {"permissions": ["read"]},
}

# ====================
# Admin角色测试
# ====================

test_admin_can_read if {
	allow with input as {"user": {"role": "admin"}, "action": "read"}
		with data.roles as test_roles
}

test_admin_can_write if {
	allow with input as {"user": {"role": "admin"}, "action": "write"}
		with data.roles as test_roles
}

test_admin_can_delete if {
	allow with input as {"user": {"role": "admin"}, "action": "delete"}
		with data.roles as test_roles
}

test_admin_can_admin if {
	allow with input as {"user": {"role": "admin"}, "action": "admin"}
		with data.roles as test_roles
}

# ====================
# Editor角色测试
# ====================

test_editor_can_read if {
	allow with input as {"user": {"role": "editor"}, "action": "read"}
		with data.roles as test_roles
}

test_editor_can_write if {
	allow with input as {"user": {"role": "editor"}, "action": "write"}
		with data.roles as test_roles
}

test_editor_cannot_delete if {
	not allow with input as {"user": {"role": "editor"}, "action": "delete"}
		with data.roles as test_roles
}

test_editor_cannot_admin if {
	not allow with input as {"user": {"role": "editor"}, "action": "admin"}
		with data.roles as test_roles
}

# ====================
# Viewer角色测试
# ====================

test_viewer_can_read if {
	allow with input as {"user": {"role": "viewer"}, "action": "read"}
		with data.roles as test_roles
}

test_viewer_cannot_write if {
	not allow with input as {"user": {"role": "viewer"}, "action": "write"}
		with data.roles as test_roles
}

test_viewer_cannot_delete if {
	not allow with input as {"user": {"role": "viewer"}, "action": "delete"}
		with data.roles as test_roles
}

test_viewer_cannot_admin if {
	not allow with input as {"user": {"role": "viewer"}, "action": "admin"}
		with data.roles as test_roles
}

# ====================
# 边界情况测试
# ====================

test_unknown_role_denied if {
	not allow with input as {"user": {"role": "unknown"}, "action": "read"}
		with data.roles as test_roles
}

test_empty_role_denied if {
	not allow with input as {"user": {"role": ""}, "action": "read"}
		with data.roles as test_roles
}

test_missing_action_denied if {
	not allow with input as {"user": {"role": "admin"}}
		with data.roles as test_roles
}

# ====================
# 拒绝原因测试
# ====================

test_deny_reason_for_viewer_write if {
	not allow with input as {"user": {"role": "viewer"}, "action": "write"}
		with data.roles as test_roles

	reason := deny_reason with input as {"user": {"role": "viewer"}, "action": "write"}
		with data.roles as test_roles

	contains(reason, "viewer")
	contains(reason, "write")
}

# ====================
# 权限集合测试
# ====================

test_admin_permissions_complete if {
	perms := user_permissions with input as {"user": {"role": "admin"}}
		with data.roles as test_roles

	count(perms) == 4
	"read" in perms
	"write" in perms
	"delete" in perms
	"admin" in perms
}

test_editor_permissions_limited if {
	perms := user_permissions with input as {"user": {"role": "editor"}}
		with data.roles as test_roles

	count(perms) == 2
	"read" in perms
	"write" in perms
}

test_viewer_permissions_minimal if {
	perms := user_permissions with input as {"user": {"role": "viewer"}}
		with data.roles as test_roles

	count(perms) == 1
	"read" in perms
}

