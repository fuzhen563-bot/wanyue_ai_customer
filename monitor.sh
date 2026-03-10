#!/bin/bash

# 万岳AI客服系统 - 监控脚本
# 每30秒检测一次程序是否运行，如进程被杀死则立刻重启

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT=8000
PID_FILE="$PROJECT_DIR/app.pid"
LOG_FILE="$PROJECT_DIR/server.log"
MONITOR_LOG="$PROJECT_DIR/monitor.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 日志函数
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$MONITOR_LOG"
}

log "========================================="
log "万岳AI客服系统 监控程序已启动"
log "监控间隔: 30秒"
log "项目路径: $PROJECT_DIR"
log "========================================="

# 清理残留进程
cleanup() {
    pkill -f "uvicorn main:app" 2>/dev/null
    sleep 1
}

# 启动主程序函数
start_app() {
    log "${YELLOW}检测到程序未运行，正在启动...${NC}"
    
    cleanup
    
    # 启动服务
    cd "$PROJECT_DIR"
    nohup python3 -m uvicorn main:app --host 0.0.0.0 --port $PORT > "$LOG_FILE" 2>&1 &
    APP_PID=$!
    
    # 保存PID
    echo $APP_PID > "$PID_FILE"
    
    # 等待服务启动
    sleep 4
    
    # 验证服务是否启动成功
    for i in {1..5}; do
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health 2>/dev/null | grep -q "200"; then
            log "${GREEN}程序启动成功! PID: $APP_PID${NC}"
            return 0
        fi
        sleep 1
    done
    
    log "${RED}程序启动失败，请检查日志: $LOG_FILE${NC}"
    return 1
}

# 监控循环
while true; do
    # 检查PID文件是否存在
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        
        # 检查进程是否在运行
        if ps -p $PID > /dev/null 2>&1; then
            # 检查服务是否正常响应
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT/health 2>/dev/null)
            
            if [ "$HTTP_CODE" = "200" ]; then
                echo -ne "\r$(date '+%Y-%m-%d %H:%M:%S') - ${GREEN}程序运行正常${NC} (PID: $PID)"
            else
                log "${YELLOW}进程存在(PID: $PID)但服务无响应(HTTP: $HTTP_CODE)，准备重启...${NC}"
                kill $PID 2>/dev/null
                sleep 2
                start_app
            fi
        else
            log "${RED}进程 $PID 不存在，程序被杀死${NC}"
            start_app
        fi
    else
        log "${RED}PID文件不存在，程序未启动${NC}"
        start_app
    fi
    
    # 等待30秒
    sleep 30
done
