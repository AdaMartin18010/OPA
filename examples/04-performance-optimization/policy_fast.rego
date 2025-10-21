package authz_fast

import rego.v1

# ✅ 优化版本：使用索引，性能优异

# 默认拒绝
default allow := false

# 优化1：直接索引查找 - O(1)
allow if {
	user := data.users[input.user_id] # O(1) 哈希查找！
	input.action in user.permissions
}

# 优化2：只查找一次，复用结果
user_info := data.users[input.user_id]

# 优化3：避免嵌套循环，使用索引
has_admin_access if {
	user_info.roles
	some role in user_info.roles
	"admin" in data.role_permissions[role]
}

# 优化4：正确的查询顺序
can_access_resource if {
	# 廉价的检查放最前
	input.user_id # 简单存在检查
	user := data.users[input.user_id] # O(1) 索引查找
	user.active == true # 布尔比较
	user.department == input.department # 字符串比较
}

# 优化5：使用Set（对象）而非数组
action_allowed if {
	# Set查找是 O(1) 哈希查找
	data.allowed_actions_set[input.action]
}

# 优化6：缓存计算结果
user_permissions contains perm if {
	some perm in user_info.permissions
}

user_roles contains role if {
	some role in user_info.roles
}

# 优化7：提前退出
quick_deny if {
	not input.user_id
}

quick_deny if {
	not data.users[input.user_id]
}

optimized_allow if {
	not quick_deny
	user_info
	input.action in user_permissions
}

