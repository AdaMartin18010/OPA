# OPA技术文档项目 - Docker镜像
# 用于构建和运行文档站点

FROM node:18-alpine AS builder

# 设置工作目录
WORKDIR /app

# 安装依赖
COPY package.json ./
RUN npm install

# 复制项目文件
COPY . .

# 构建文档
WORKDIR /app/docs
RUN npm run build

# 生产环境镜像
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/docs/.vuepress/dist /usr/share/nginx/html

# 复制nginx配置
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

# 暴露端口
EXPOSE 80

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]
