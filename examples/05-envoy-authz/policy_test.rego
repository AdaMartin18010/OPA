package envoy.authz

import rego.v1

# ================================================================
# Envoy Authorization Policy - Test Suite
# ================================================================

# ────────────────────────────────────────────────────────────────
# 测试数据：JWT Tokens
# ────────────────────────────────────────────────────────────────

# Admin token (role: admin, exp: 9999999999)
# Header: {"alg":"HS256","typ":"JWT"}
# Payload: {"sub":"admin1","role":"admin","exp":9999999999}
# Secret: supersecretkey123
admin_token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbjEiLCJyb2xlIjoiYWRtaW4iLCJleHAiOjk5OTk5OTk5OTl9.qTxSxN8ZNdXMGqI3L8Cqnj7HJZVMVa8Wqq2SqZ4GVQU"

# User token (role: user, exp: 9999999999)
user_token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMSIsInJvbGUiOiJ1c2VyIiwiZXhwIjo5OTk5OTk5OTk5fQ.2mD8L5D8ZQqY5L8ZQqY5L8ZQqY5L8ZQqY5L8ZQqY5L"

# Guest token (role: guest, exp: 9999999999)
guest_token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJndWVzdDEiLCJyb2xlIjoiZ3Vlc3QiLCJleHAiOjk5OTk5OTk5OTl9.3nE9M6E9aRrZ6M9aRrZ6M9aRrZ6M9aRrZ6M9aRrZ6M"

# Expired token (exp: 1)
expired_token := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMiIsInJvbGUiOiJ1c2VyIiwiZXhwIjoxfQ.4oF0N7F0bSsA7N0bSsA7N0bSsA7N0bSsA7N0bSsA7N"

# ────────────────────────────────────────────────────────────────
# 测试：Admin权限
# ────────────────────────────────────────────────────────────────

test_admin_can_access_admin_users_get if {
	allow with input as mock_request("GET", "/api/admin/users", admin_token)
}

test_admin_can_access_admin_users_post if {
	allow with input as mock_request("POST", "/api/admin/users", admin_token)
}

test_admin_can_access_admin_users_delete if {
	allow with input as mock_request("DELETE", "/api/admin/users", admin_token)
}

test_admin_can_access_admin_roles if {
	allow with input as mock_request("GET", "/api/admin/roles", admin_token)
}

test_admin_can_access_admin_settings if {
	allow with input as mock_request("PUT", "/api/admin/settings", admin_token)
}

test_admin_can_access_user_api if {
	allow with input as mock_request("GET", "/api/users/profile", admin_token)
}

test_admin_can_access_user_wildcard if {
	allow with input as mock_request("GET", "/api/users/123/posts", admin_token)
}

test_admin_can_access_data_api if {
	allow with input as mock_request("POST", "/api/data/reports", admin_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：User权限
# ────────────────────────────────────────────────────────────────

test_user_can_access_own_profile if {
	allow with input as mock_request("GET", "/api/users/profile", user_token)
}

test_user_can_update_own_profile if {
	allow with input as mock_request("PUT", "/api/users/profile", user_token)
}

test_user_cannot_delete_profile if {
	not allow with input as mock_request("DELETE", "/api/users/profile", user_token)
}

test_user_can_read_data if {
	allow with input as mock_request("GET", "/api/data/reports", user_token)
}

test_user_cannot_write_data if {
	not allow with input as mock_request("POST", "/api/data/reports", user_token)
}

test_user_cannot_access_admin_api if {
	not allow with input as mock_request("GET", "/api/admin/users", user_token)
}

test_user_cannot_access_admin_roles if {
	not allow with input as mock_request("GET", "/api/admin/roles", user_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：Guest权限
# ────────────────────────────────────────────────────────────────

test_guest_can_access_public_api if {
	allow with input as mock_request("GET", "/api/public/info", guest_token)
}

test_guest_cannot_access_user_api if {
	not allow with input as mock_request("GET", "/api/users/profile", guest_token)
}

test_guest_cannot_access_admin_api if {
	not allow with input as mock_request("GET", "/api/admin/users", guest_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：Token验证
# ────────────────────────────────────────────────────────────────

test_expired_token_denied if {
	not allow with input as mock_request("GET", "/api/users/profile", expired_token)
}

test_invalid_token_denied if {
	not allow with input as mock_request("GET", "/api/users/profile", "invalid.token.here")
}

test_missing_token_denied if {
	not allow with input as mock_request_no_auth("GET", "/api/users/profile")
}

test_malformed_auth_header_denied if {
	not allow with input as {
		"attributes": {
			"request": {"http": {
				"method": "GET",
				"path": "/api/users/profile",
				"headers": {"authorization": "BadFormat token123"},
			}},
			"source": {"address": {"socketAddress": {"address": "192.168.1.1"}}},
		},
	}
}

# ────────────────────────────────────────────────────────────────
# 测试：公开路径
# ────────────────────────────────────────────────────────────────

test_health_endpoint_public if {
	allow with input as mock_request_no_auth("GET", "/health")
}

test_public_info_no_auth if {
	allow with input as mock_request_no_auth("GET", "/api/public/info")
}

test_public_docs_no_auth if {
	allow with input as mock_request_no_auth("GET", "/api/public/docs")
}

# ────────────────────────────────────────────────────────────────
# 测试：路径通配符匹配
# ────────────────────────────────────────────────────────────────

test_admin_wildcard_users_nested_path if {
	allow with input as mock_request("GET", "/api/users/123/posts/456", admin_token)
}

test_user_cannot_access_nested_users_path if {
	not allow with input as mock_request("POST", "/api/users/123/admin", user_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：HTTP方法限制
# ────────────────────────────────────────────────────────────────

test_user_cannot_post_to_profile if {
	not allow with input as mock_request("POST", "/api/users/profile", user_token)
}

test_admin_can_use_all_methods if {
	allow with input as mock_request("GET", "/api/admin/users", admin_token)
	allow with input as mock_request("POST", "/api/admin/users", admin_token)
	allow with input as mock_request("PUT", "/api/admin/users", admin_token)
	allow with input as mock_request("DELETE", "/api/admin/users", admin_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：拒绝原因
# ────────────────────────────────────────────────────────────────

test_deny_reason_missing_token if {
	deny_reason == "missing_token" with input as mock_request_no_auth("GET", "/api/users/profile")
}

test_deny_reason_invalid_token if {
	deny_reason == "invalid_token" with input as mock_request("GET", "/api/users/profile", "bad-token")
}

test_deny_reason_expired_token if {
	deny_reason == "expired_token" with input as mock_request("GET", "/api/users/profile", expired_token)
}

test_deny_reason_insufficient_permissions if {
	deny_reason == "insufficient_permissions" with input as mock_request("GET", "/api/admin/users", user_token)
}

# ────────────────────────────────────────────────────────────────
# 测试：响应头
# ────────────────────────────────────────────────────────────────

test_response_headers_on_allow if {
	headers := response_headers with input as mock_request("GET", "/api/users/profile", user_token)
	headers["x-opa-decision"] == "allowed"
	headers["x-user-id"] == "user1"
	headers["x-user-role"] == "user"
}

test_response_headers_on_deny if {
	headers := response_headers with input as mock_request("GET", "/api/admin/users", user_token)
	headers["x-opa-decision"] == "denied"
	headers["x-reason"] == "insufficient_permissions"
}

# ────────────────────────────────────────────────────────────────
# 辅助函数：Mock请求
# ────────────────────────────────────────────────────────────────

# 带认证的请求
mock_request(method, path, token) := {
	"attributes": {
		"request": {"http": {
			"method": method,
			"path": path,
			"headers": {"authorization": concat("", ["Bearer ", token])},
		}},
		"source": {"address": {"socketAddress": {"address": "192.168.1.100"}}},
	},
}

# 无认证的请求
mock_request_no_auth(method, path) := {
	"attributes": {
		"request": {"http": {
			"method": method,
			"path": path,
			"headers": {},
		}},
		"source": {"address": {"socketAddress": {"address": "192.168.1.100"}}},
	},
}

