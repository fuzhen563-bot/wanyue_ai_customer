#!/bin/bash

# 万岳AI客服系统 - 状态检查脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$PROJECT_DIR/app.pid"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 万岳AI客服系统状态 ===${NC}"
echo ""

# 检查进程状态
if [ -f "$PID_FILE" ]; then
    APP_PID=$(cat "$PID_FILE")
    if ps -p $APP_PID > /dev/null 2>&1; then
        echo -e "服务状态: ${GREEN}运行中${NC}"
        echo "进程PID:  $APP_PID"
    else
        echo -e "服务状态: ${RED}已停止${NC} (PID文件存在但进程不存在)"
    fi
else
    # 尝试通过端口查找
    PID=$(lsof -ti:8000 2>/dev/null)
    if [ -n "$PID" ]; then
        echo -e "服务状态: ${GREEN}运行中${NC}"
        echo "进程PID:  $PID"
    else
        echo -e "服务状态: ${RED}已停止${NC}"
    fi
fi

# 检查端口
echo ""
if netstat -tuln 2>/dev/null | grep -q ":8000 " || ss -tuln 2>/dev/null | grep -q ":8000 "; then
    echo -e "端口8000: ${GREEN}监听中${NC}"
else
    echo -e "端口8000: ${RED}未监听${NC}"
fi

# 检查日志
echo ""
echo "最近日志 (最后10行):"
echo "----------------------------------------"
if [ -f "$PROJECT_DIR/server.log" ]; then
    tail -n 10 "$PROJECT_DIR/server.log"
else
    echo "日志文件不存在"
fi
echo "----------------------------------------"

# 尝试健康检查
echo ""
echo "健康检查:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health 2>/dev/null | grep -q "200"; then
    echo -e "API状态: ${GREEN}正常${NC}"
else
    echo -e "API状态: ${RED}异常${NC}"
fi
