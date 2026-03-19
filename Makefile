# OPA技术文档项目 - Makefile
# 提供项目构建、测试、部署的自动化命令

.PHONY: help install test lint build deploy clean verify benchmark

# 默认目标
.DEFAULT_GOAL := help

# 颜色定义
BLUE := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
NC := \033[0m # No Color

# 项目信息
PROJECT_NAME := OPA技术文档
PROJECT_VERSION := 2.6.0
OPA_VERSION := 1.4.0

help: ## 显示帮助信息
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  $(PROJECT_NAME) v$(PROJECT_VERSION)$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo ""
	@echo "$(GREEN)可用命令:$(NC)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)示例:$(NC)"
	@echo "  make test           # 运行所有测试"
	@echo "  make lint           # 检查代码规范"
	@echo "  make build          # 构建文档站点"
	@echo "  make verify         # 全面验证项目"

install: ## 安装项目依赖
	@echo "$(BLUE)正在安装依赖...$(NC)"
	npm install
	@echo "$(GREEN)✅ 依赖安装完成$(NC)"

install-opa: ## 安装OPA v1.4.0
	@echo "$(BLUE)正在安装OPA v$(OPA_VERSION)...$(NC)"
	@if [ "$$(uname)" = "Darwin" ]; then \
		curl -L -o opa https://openpolicyagent.org/downloads/v$(OPA_VERSION)/opa_darwin_amd64_static; \
	else \
		curl -L -o opa https://openpolicyagent.org/downloads/v$(OPA_VERSION)/opa_linux_amd64_static; \
	fi
	@chmod 755 opa
	@sudo mv opa /usr/local/bin/
	@echo "$(GREEN)✅ OPA v$(OPA_VERSION) 安装完成$(NC)"
	@opa version

test: ## 运行所有测试
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  运行测试套件$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@./scripts/run-all-tests.sh

test-examples: ## 测试所有示例
	@echo "$(BLUE)测试代码示例...$(NC)"
	@for dir in examples/*/; do \
		if [ -f "$$dir/policy_test.rego" ]; then \
			echo "$(YELLOW)测试: $$(basename $$dir)$(NC)"; \
			cd "$$dir" && opa test . -v && cd ../..; \
		fi \
	done
	@echo "$(GREEN)✅ 所有示例测试通过$(NC)"

test-docs: ## 验证文档完整性
	@echo "$(BLUE)验证文档...$(NC)"
	@./scripts/verify-docs.sh

lint: ## 检查代码规范
	@echo "$(BLUE)检查Reg代码规范...$(NC)"
	@find examples/ -name "*.rego" -exec opa fmt -d {} \;
	@echo "$(BLUE)检查Markdown格式...$(NC)"
	@npx markdownlint-cli docs/*.md docs/**/*.md --ignore CHANGELOG.md || true
	@echo "$(GREEN)✅ 代码规范检查完成$(NC)"

lint-fix: ## 自动修复代码格式
	@echo "$(BLUE)修复Reg代码格式...$(NC)"
	@find examples/ -name "*.rego" -exec opa fmt -w {} \;
	@echo "$(GREEN)✅ 代码格式已修复$(NC)"

build: ## 构建VuePress文档站点
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  构建文档站点$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@cd docs && npm run build
	@echo "$(GREEN)✅ 构建完成，输出目录: docs/.vuepress/dist$(NC)"

dev: ## 启动开发服务器
	@echo "$(BLUE)启动开发服务器...$(NC)"
	@cd docs && npm run dev

deploy: build ## 部署到GitHub Pages
	@echo "$(BLUE)部署到GitHub Pages...$(NC)"
	@./scripts/deploy.sh
	@echo "$(GREEN)✅ 部署完成$(NC)"

verify: ## 全面验证项目完整性
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  全面项目验证$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@./scripts/verify-project.sh

benchmark: ## 运行性能基准测试
	@echo "$(BLUE)运行性能基准测试...$(NC)"
	@cd examples/04-performance-optimization && ./benchmark.sh

clean: ## 清理构建产物
	@echo "$(BLUE)清理构建产物...$(NC)"
	@rm -rf docs/.vuepress/dist
	@rm -rf node_modules
	@find . -name "*.log" -delete
	@find . -name ".DS_Store" -delete
	@echo "$(GREEN)✅ 清理完成$(NC)"

stats: ## 显示项目统计
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(BLUE)  项目统计$(NC)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"
	@echo "$(GREEN)文档统计:$(NC)"
	@echo "  核心文档: $$(find docs -name "*.md" | wc -l) 篇"
	@echo "  根目录文档: $$(ls *.md 2>/dev/null | wc -l) 篇"
	@echo "  总字数: $$(find docs -name "*.md" -exec wc -c {} + | tail -1 | awk '{print int($$1/1000)}')K+"
	@echo ""
	@echo "$(GREEN)代码统计:$(NC)"
	@echo "  示例项目: $$(ls -d examples/*/ 2>/dev/null | wc -l) 个"
	@echo "  Rego文件: $$(find examples -name "*.rego" | wc -l) 个"
	@echo "  测试文件: $$(find examples -name "*_test.rego" | wc -l) 个"
	@echo ""
	@echo "$(GREEN)版本信息:$(NC)"
	@echo "  项目版本: $(PROJECT_VERSION)"
	@echo "  OPA版本: $(OPA_VERSION)"
	@echo "$(BLUE)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$(NC)"

security-check: ## 安全检查
	@echo "$(BLUE)运行安全检查...$(NC)"
	@echo "$(YELLOW)检查CVE-2025-46569...$(NC)"
	@opa version | grep -E "Version:\s*(1\.[4-9]|[2-9])" > /dev/null && echo "$(GREEN)✅ OPA版本安全$(NC)" || echo "$(RED)❌ 请升级到OPA v1.4+$(NC)"
	@./scripts/security-check.sh

update-opa: ## 更新OPA到最新版本
	@echo "$(BLUE)检查OPA最新版本...$(NC)"
	@curl -s https://api.github.com/repos/open-policy-agent/opa/releases/latest | grep tag_name | cut -d'"' -f4
	@echo "$(YELLOW)使用 'make install-opa' 安装特定版本$(NC)"

# CI/CD 相关
ci-test: test-examples lint ## CI测试（用于GitHub Actions）
	@echo "$(GREEN)✅ CI测试通过$(NC)"

# 文档生成
generate-index: ## 生成文档索引
	@echo "$(BLUE)生成文档索引...$(NC)"
	@./scripts/generate-index.sh

generate-sitemap: ## 生成站点地图
	@echo "$(BLUE)生成站点地图...$(NC)"
	@cd docs && npm run build

# 开发工具
format: lint-fix ## 格式化所有代码（别名）

check: verify ## 验证项目（别名）

# 帮助文档
show-structure: ## 显示项目结构
	@tree -L 2 -I 'node_modules|.git|dist' || find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git

# 版本信息
version: ## 显示版本信息
	@echo "$(PROJECT_NAME) v$(PROJECT_VERSION)"
	@echo "OPA版本: $(OPA_VERSION)"
	@echo "最后更新: $$(git log -1 --format=%cd --date=short 2>/dev/null || echo '未知')"
