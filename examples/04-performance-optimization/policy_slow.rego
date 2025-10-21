package authz_slow

import rego.v1

# ❌ 未优化版本：全表扫描，性能差

# 默认拒绝
default allow := false

# 问题1：全表扫描 - 遍历所有用户查找
allow if {
	some user in data.users # O(n) 全表扫描！
	user.id == input.user_id
	input.action in user.permissions
}

# 问题2：重复查找用户
user_info := user if {
	some user in data.users
	user.id == input.user_id
}

# 问题3：嵌套循环 - 性能灾难
has_admin_access if {
	some user in data.users # O(n)
	user.id == input.user_id
	some role in user.roles # O(m)
	some perm in data.role_permissions[role] # O(k)
	perm == "admin" # 总复杂度 O(n*m*k)
}

# 问题4：错误的查询顺序
can_access_resource if {
	some user in data.users # 昂贵：全表扫描
	user.department == input.department # 昂贵：字符串比较
	user.active == true # 昂贵：多个条件
	user.id == input.user_id # 应该最先检查！
}

# 问题5：使用数组而非Set
action_allowed if {
	# 数组的 in 操作是 O(n) 线性查找
	input.action in data.allowed_actions_array
}

