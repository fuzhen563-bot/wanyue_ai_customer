#!/bin/bash

# 万岳AI客服系统 - 重启脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 万岳AI客服系统重启 ===${NC}"

# 停止服务
echo "停止服务..."
"$PROJECT_DIR/stop.sh"

# 等待一下
sleep 2

# 启动服务
echo "启动服务..."
"$PROJECT_DIR/start.sh"
