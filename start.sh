#!/bin/bash

# 万岳AI客服系统 - 启动脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$PROJECT_DIR/app.pid"
LOG_FILE="$PROJECT_DIR/server.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== 万岳AI客服系统启动脚本 ===${NC}"

# 检查Python环境
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}错误: 未找到Python3，请先安装Python3.8+${NC}"
    exit 1
fi

# 检查依赖
echo -e "${YELLOW}[1/4] 检查依赖...${NC}"
cd "$PROJECT_DIR"

if [ ! -f "requirements.txt" ]; then
    echo -e "${RED}错误: 未找到requirements.txt文件${NC}"
    exit 1
fi

# 检查.env文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}警告: 未找到.env文件，正在从示例创建...${NC}"
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${YELLOW}请编辑 .env 文件配置相关参数${NC}"
    fi
fi

# 启动服务
echo -e "${YELLOW}[2/4] 启动FastAPI服务...${NC}"

# 后台启动
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload > "$LOG_FILE" 2>&1 &
APP_PID=$!

# 保存PID
echo $APP_PID > "$PID_FILE"

# 等待服务启动
echo -e "${YELLOW}[3/4] 等待服务启动...${NC}"
sleep 3

# 检查服务是否启动成功
if ps -p $APP_PID > /dev/null 2>&1; then
    echo -e "${GREEN}[4/4] 服务启动成功!${NC}"
    echo ""
    echo -e "${GREEN}=======================================${NC}"
    echo -e "${GREEN}  万岳AI客服系统 已成功启动${NC}"
    echo -e "${GREEN}=======================================${NC}"
    echo ""
    echo "访问地址:"
    echo "  - 前端页面:  http://localhost:8000/app"
    echo "  - 管理后台:  http://localhost:8000/admin"
    echo "  - 登录页面:  http://localhost:8000/login"
    echo "  - API文档:   http://localhost:8000/docs"
    echo "  - 健康检查:  http://localhost:8000/health"
    echo ""
    echo "日志文件: $LOG_FILE"
    echo "进程PID:  $APP_PID"
    echo ""
else
    echo -e "${RED}服务启动失败，请检查日志: $LOG_FILE${NC}"
    exit 1
fi
