#!/bin/bash

# 万岳AI客服系统 - 停止脚本

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$PROJECT_DIR/app.pid"
LOG_FILE="$PROJECT_DIR/server.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== 万岳AI客服系统停止脚本 ===${NC}"

# 检查PID文件
if [ -f "$PID_FILE" ]; then
    APP_PID=$(cat "$PID_FILE")
    
    # 检查进程是否存在
    if ps -p $APP_PID > /dev/null 2>&1; then
        echo -e "${YELLOW}正在停止服务 (PID: $APP_PID)...${NC}"
        
        # 发送SIGTERM信号
        kill $APP_PID 2>/dev/null
        
        # 等待进程结束
        for i in {1..10}; do
            if ! ps -p $APP_PID > /dev/null 2>&1; then
                echo -e "${GREEN}服务已停止${NC}"
                rm -f "$PID_FILE"
                break
            fi
            sleep 1
        done
        
        # 如果进程仍未结束，强制杀死
        if ps -p $APP_PID > /dev/null 2>&1; then
            echo -e "${YELLOW}强制终止进程...${NC}"
            kill -9 $APP_PID 2>/dev/null
            rm -f "$PID_FILE"
            echo -e "${GREEN}服务已强制停止${NC}"
        fi
    else
        echo -e "${YELLOW}服务进程不存在，可能已经停止${NC}"
        rm -f "$PID_FILE"
    fi
else
    # 尝试通过端口查找进程
    echo -e "${YELLOW}未找到PID文件，尝试通过端口查找进程...${NC}"
    
    # 查找占用8000端口的进程
    PID=$(lsof -ti:8000 2>/dev/null)
    
    if [ -n "$PID" ]; then
        echo -e "${YELLOW}找到进程 (PID: $PID)，正在停止...${NC}"
        kill $PID 2>/dev/null
        sleep 2
        
        if ps -p $PID > /dev/null 2>&1; then
            kill -9 $PID 2>/dev/null
        fi
        
        echo -e "${GREEN}服务已停止${NC}"
    else
        echo -e "${YELLOW}未找到运行中的服务${NC}"
    fi
fi

echo ""
echo -e "${GREEN}操作完成${NC}"
echo "日志文件保留在: $LOG_FILE"
