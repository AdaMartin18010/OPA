package envoy.authz

import rego.v1

# ================================================================
# Envoy External Authorization Policy
# 场景: API网关授权，JWT验证 + RBAC
# ================================================================

# 默认拒绝所有请求
default allow := false

# ────────────────────────────────────────────────────────────────
# 主决策规则
# ────────────────────────────────────────────────────────────────

# 允许请求的条件：
# 1. Token有效且未过期
# 2. 用户有权限访问请求的路径
allow if {
	valid_token
	not_expired
	has_permission
}

# 公开接口无需认证
allow if {
	is_public_path
}

# ────────────────────────────────────────────────────────────────
# Token验证
# ────────────────────────────────────────────────────────────────

# 提取Authorization header中的token
token := t if {
	auth_header := input.attributes.request.http.headers.authorization
	startswith(auth_header, "Bearer ")
	t := substring(auth_header, 7, -1)
}

# Token验证（使用HS256算法）
valid_token if {
	token != ""
	io.jwt.verify_hs256(token, jwt_secret)
}

# JWT密钥（生产环境应从外部配置加载）
jwt_secret := "supersecretkey123"

# 解码token获取payload
token_payload := payload if {
	[_, payload, _] := io.jwt.decode(token)
}

# 检查token是否过期
not_expired if {
	token_payload.exp > time.now_ns() / 1000000000
}

# 获取用户角色
user_role := token_payload.role

# 获取用户ID
user_id := token_payload.sub

# ────────────────────────────────────────────────────────────────
# 权限检查
# ────────────────────────────────────────────────────────────────

# 检查用户是否有权限访问请求的路径
has_permission if {
	# 获取请求信息
	path := input.attributes.request.http.path
	method := input.attributes.request.http.method

	# 查找权限表
	allowed_methods := permissions[user_role][path]
	method in allowed_methods
}

# 路径模式匹配
has_permission if {
	path := input.attributes.request.http.path
	method := input.attributes.request.http.method

	# 遍历权限表中的路径模式
	some pattern in object.keys(permissions[user_role])
	path_matches(path, pattern)
	method in permissions[user_role][pattern]
}

# 路径匹配函数
path_matches(path, pattern) if {
	# 精确匹配
	path == pattern
}

path_matches(path, pattern) if {
	# 通配符匹配 (例如: /api/users/*)
	endswith(pattern, "/*")
	prefix := trim_suffix(pattern, "*")
	startswith(path, prefix)
}

# ────────────────────────────────────────────────────────────────
# 权限矩阵
# ────────────────────────────────────────────────────────────────

permissions := {
	"admin": {
		# 管理员接口
		"/api/admin/users": {"GET", "POST", "PUT", "DELETE"},
		"/api/admin/roles": {"GET", "POST", "PUT", "DELETE"},
		"/api/admin/settings": {"GET", "PUT"},
		# 用户接口（全权限）
		"/api/users/*": {"GET", "POST", "PUT", "DELETE"},
		# 数据接口
		"/api/data/*": {"GET", "POST", "PUT", "DELETE"},
	},
	"user": {
		# 用户自己的资源
		"/api/users/profile": {"GET", "PUT"},
		"/api/users/settings": {"GET", "PUT"},
		# 数据只读
		"/api/data/*": {"GET"},
	},
	"guest": {
		# 公开只读接口
		"/api/public/*": {"GET"},
	},
}

# ────────────────────────────────────────────────────────────────
# 公开路径（无需认证）
# ────────────────────────────────────────────────────────────────

is_public_path if {
	public_paths := {
		"/health",
		"/api/public/info",
		"/api/public/docs",
	}

	input.attributes.request.http.path in public_paths
}

# ────────────────────────────────────────────────────────────────
# 响应增强
# ────────────────────────────────────────────────────────────────

# 返回给Envoy的响应头
response_headers := {
	"x-opa-decision": "allowed",
	"x-user-id": user_id,
	"x-user-role": user_role,
} if {
	allow
}

response_headers := {
	"x-opa-decision": "denied",
	"x-reason": deny_reason,
} if {
	not allow
}

# 拒绝原因
deny_reason := "missing_token" if {
	not token
}

deny_reason := "invalid_token" if {
	token
	not valid_token
}

deny_reason := "expired_token" if {
	token
	valid_token
	not not_expired
}

deny_reason := "insufficient_permissions" if {
	token
	valid_token
	not_expired
	not has_permission
	not is_public_path
}

# ────────────────────────────────────────────────────────────────
# 决策日志
# ────────────────────────────────────────────────────────────────

# 记录关键信息用于审计
log_entry := {
	"decision": allow,
	"user_id": user_id,
	"role": user_role,
	"path": input.attributes.request.http.path,
	"method": input.attributes.request.http.method,
	"source_ip": input.attributes.source.address.socketAddress.address,
	"timestamp": time.now_ns(),
	"reason": deny_reason,
} if {
	token
}

log_entry := {
	"decision": allow,
	"path": input.attributes.request.http.path,
	"method": input.attributes.request.http.method,
	"source_ip": input.attributes.source.address.socketAddress.address,
	"timestamp": time.now_ns(),
	"reason": "anonymous_request",
} if {
	not token
}

