package authz_test

import rego.v1

import data.authz_fast
import data.authz_slow

# 测试数据
test_users := {"user1": {
	"id": "user1",
	"name": "Alice",
	"department": "engineering",
	"active": true,
	"roles": ["developer", "admin"],
	"permissions": ["read", "write"],
}}

test_role_permissions := {
	"developer": ["read", "write"],
	"admin": ["read", "write", "delete", "admin"],
}

test_allowed_actions_set := {
	"read": true,
	"write": true,
	"delete": true,
}

test_input := {
	"user_id": "user1",
	"action": "read",
	"department": "engineering",
}

# ====================
# 慢版本功能测试
# ====================

test_slow_allow_basic if {
	authz_slow.allow with input as test_input
		with data.users as test_users
}

test_slow_deny_invalid_user if {
	not authz_slow.allow with input as {"user_id": "invalid", "action": "read"}
		with data.users as test_users
}

test_slow_deny_no_permission if {
	not authz_slow.allow with input as {"user_id": "user1", "action": "admin"}
		with data.users as test_users
}

# ====================
# 快版本功能测试
# ====================

test_fast_allow_basic if {
	authz_fast.allow with input as test_input
		with data.users as test_users
}

test_fast_deny_invalid_user if {
	not authz_fast.allow with input as {"user_id": "invalid", "action": "read"}
		with data.users as test_users
}

test_fast_deny_no_permission if {
	not authz_fast.allow with input as {"user_id": "user1", "action": "admin"}
		with data.users as test_users
}

# ====================
# Admin访问测试
# ====================

test_fast_has_admin_access if {
	authz_fast.has_admin_access with input as test_input
		with data.users as test_users
		with data.role_permissions as test_role_permissions
}

# ====================
# 资源访问测试
# ====================

test_fast_can_access_resource if {
	authz_fast.can_access_resource with input as test_input
		with data.users as test_users
}

test_fast_cannot_access_wrong_department if {
	not authz_fast.can_access_resource with input as {
		"user_id": "user1",
		"department": "sales",
	} with data.users as test_users
}

# ====================
# Set操作测试
# ====================

test_fast_action_allowed if {
	authz_fast.action_allowed with input as {"action": "read"}
		with data.allowed_actions_set as test_allowed_actions_set
}

test_fast_action_not_allowed if {
	not authz_fast.action_allowed with input as {"action": "execute"}
		with data.allowed_actions_set as test_allowed_actions_set
}

# ====================
# 快速拒绝测试
# ====================

test_fast_quick_deny_no_user_id if {
	authz_fast.quick_deny with input as {"action": "read"}
}

test_fast_quick_deny_invalid_user if {
	authz_fast.quick_deny with input as {"user_id": "invalid"}
		with data.users as test_users
}

# ====================
# 优化版allow测试
# ====================

test_fast_optimized_allow if {
	authz_fast.optimized_allow with input as test_input
		with data.users as test_users
}

test_fast_optimized_deny_quick if {
	not authz_fast.optimized_allow with input as {"action": "read"}
		with data.users as test_users
}

# ====================
# 对比测试：确保两个版本结果一致
# ====================

test_slow_fast_consistency_allow if {
	slow_result := authz_slow.allow with input as test_input
		with data.users as test_users

	fast_result := authz_fast.allow with input as test_input
		with data.users as test_users

	slow_result == fast_result
}

test_slow_fast_consistency_deny if {
	slow_result := authz_slow.allow with input as {"user_id": "invalid", "action": "read"}
		with data.users as test_users

	fast_result := authz_fast.allow with input as {"user_id": "invalid", "action": "read"}
		with data.users as test_users

	slow_result == fast_result
}

# ====================
# 边界条件测试
# ====================

test_fast_empty_permissions if {
	not authz_fast.allow with input as {"user_id": "user1", "action": "read"}
		with data.users as {"user1": {
			"id": "user1",
			"permissions": [],
		}}
}

test_fast_missing_user if {
	not authz_fast.allow with input as {"user_id": "nonexistent", "action": "read"}
		with data.users as test_users
}

test_fast_null_action if {
	not authz_fast.allow with input as {"user_id": "user1"}
		with data.users as test_users
}

# ====================
# 缓存效果测试
# ====================

test_fast_user_permissions if {
	perms := authz_fast.user_permissions with input as test_input
		with data.users as test_users

	"read" in perms
	"write" in perms
	count(perms) == 2
}

test_fast_user_roles if {
	roles := authz_fast.user_roles with input as test_input
		with data.users as test_users

	"developer" in roles
	"admin" in roles
	count(roles) == 2
}

