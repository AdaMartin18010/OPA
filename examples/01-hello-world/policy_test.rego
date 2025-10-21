package example.hello

import rego.v1

# 测试admin用户访问
test_admin_allowed if {
	allow with input as {"user": {"role": "admin", "name": "Alice", "id": "1"}, "resource": {"owner": "2"}}
}

# 测试资源所有者访问
test_owner_allowed if {
	allow with input as {"user": {"role": "user", "name": "Bob", "id": "2"}, "resource": {"owner": "2"}}
}

# 测试拒绝访问
test_deny_access if {
	not allow with input as {"user": {"role": "user", "name": "Charlie", "id": "3"}, "resource": {"owner": "2"}}
}

# 测试欢迎消息
test_greeting_admin if {
	greeting == "Hello, Alice! Welcome to OPA." with input as {"user": {"role": "admin", "name": "Alice", "id": "1"}, "resource": {"owner": "2"}}
}

# 测试拒绝消息
test_greeting_denied if {
	greeting == "Access Denied" with input as {"user": {"role": "user", "name": "Charlie", "id": "3"}, "resource": {"owner": "2"}}
}

