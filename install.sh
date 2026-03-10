#!/bin/bash

# ============================================
# 万岳AI客服系统 - 一键安装脚本
# ============================================
# Copyright © 2026 亦梓科技有限公司 (Yizi Technology)
# Copyright © 2026 万岳科技 (Wanyue Technology - 分公司)
# All Rights Reserved
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 版权信息
show_copyright() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                        ${YELLOW}万岳AI客服系统${NC}                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                         一键安装脚本 v1.0.0                                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                              版权声明                                       ${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}© 2026 亦梓科技有限公司 (Yizi Technology Co., Ltd.)${NC}"
    echo -e "${YELLOW}© 2026 万岳科技 (Wanyue Technology - 分公司)${NC}"
    echo ""
    echo -e "${GREEN}版权所有，侵权必究${NC}"
    echo ""
    echo -e "${RED}未经授权，禁止以下行为：${NC}"
    echo -e "  • 反编译或逆向工程"
    echo -e "  • 未经授权的商业使用"
    echo -e "  • 删除或修改版权信息"
    echo -e "  • 再分发或转让本软件"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}正在初始化安装环境...${NC}"
    sleep 2
}

# 欢迎信息
show_welcome() {
    echo ""
    echo -e "${GREEN}欢迎使用 万岳AI客服系统 一键安装脚本${NC}"
    echo ""
    echo -e "${YELLOW}本脚本将为您完成以下操作：${NC}"
    echo "  1. 检查系统环境"
    echo "  2. 配置域名（可选）"
    echo "  3. 安装Python依赖"
    echo "  4. 初始化数据库"
    echo "  5. 配置Nginx"
    echo "  6. 启动服务"
    echo ""
    echo -e "${YELLOW}按任意键继续安装...${NC}"
    read -n 1 -s
    echo ""
}

# 域名配置
configure_domain() {
    echo ""
    echo -e "${CYAN}▸ 配置域名（可选）...${NC}"
    echo ""
    echo -e "${YELLOW}请选择配置方式：${NC}"
    echo "  1) 直接使用IP地址（跳过域名配置）"
    echo "  2) 使用已有域名（自动配置SSL）"
    echo "  3) 仅配置HTTP（不申请SSL证书）"
    echo ""
    echo -ne "${GREEN}请输入选项 [1-3]: ${NC}"
    read DOMAIN_CHOICE
    
    case $DOMAIN_CHOICE in
        1)
            DOMAIN=""
            SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
            echo -e "  ✓ 使用IP地址: ${SERVER_IP}"
            ;;
        2)
            echo -ne "${GREEN}请输入您的域名: ${NC}"
            read DOMAIN
            if [ -z "$DOMAIN" ]; then
                echo -e "${YELLOW}  ⚠ 未输入域名，使用IP地址${NC}"
                DOMAIN=""
                SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
            else
                echo -e "  ✓ 域名: $DOMAIN"
                # 检查DNS解析
                echo -e "  • 检查DNS解析..."
                DOMAIN_IP=$(dig +short $DOMAIN | tail -1)
                SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
                if [ "$DOMAIN_IP" != "$SERVER_IP" ]; then
                    echo -e "${YELLOW}  ⚠ 警告: 域名DNS未指向本服务器${NC}"
                    echo -e "${YELLOW}  ⚠ 请确保域名已解析到: ${SERVER_IP}${NC}"
                fi
            fi
            ;;
        3)
            echo -ne "${GREEN}请输入您的域名: ${NC}"
            read DOMAIN
            if [ -z "$DOMAIN" ]; then
                echo -e "${YELLOW}  ⚠ 未输入域名，使用IP地址${NC}"
                DOMAIN=""
            else
                echo -e "  ✓ 域名: $DOMAIN (HTTP模式)"
            fi
            ;;
        *)
            DOMAIN=""
            SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
            echo -e "  ✓ 使用IP地址: ${SERVER_IP}"
            ;;
    esac
    
    # 保存配置到文件
    cat > /data/wanyue-ai-customer/.env.install << EOF
DOMAIN=$DOMAIN
SERVER_IP=$SERVER_IP
EOF
    
    echo ""
}

# 检查系统
check_system() {
    echo ""
    echo -e "${CYAN}▸ 检查系统环境...${NC}"
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ Python3 未安装，请先安装Python 3.8+${NC}"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo -e "  ✓ Python 版本: $PYTHON_VERSION"
    
    # 检查pip
    if ! command -v pip3 &> /dev/null && ! python3 -m pip &> /dev/null; then
        echo -e "${RED}✗ pip 未安装，请先安装pip${NC}"
        exit 1
    fi
    echo -e "  ✓ pip 已安装"
    
    # 检查内存
    MEMORY=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}' || echo "1024")
    if [ "$MEMORY" -lt 512 ]; then
        echo -e "${YELLOW}⚠ 建议内存至少 512MB，当前 ${MEMORY}MB${NC}"
    else
        echo -e "  ✓ 内存: ${MEMORY}MB"
    fi
    
    echo -e "${GREEN}  ✓ 系统检查完成${NC}"
    echo ""
}

# 安装依赖
install_dependencies() {
    echo -e "${CYAN}▸ 安装Python依赖...${NC}"
    
    # 升级pip
    echo -e "  • 升级pip..."
    pip3 install --upgrade pip --quiet 2>/dev/null || python3 -m pip install --upgrade pip --quiet 2>/dev/null || true
    
    # 安装依赖
    echo -e "  • 安装核心依赖..."
    pip3 install fastapi uvicorn sqlalchemy pydantic python-multipart python-jose passlib bcrypt python-dotenv aiofiles --quiet 2>/dev/null || true
    
    # 安装额外依赖
    echo -e "  • 安装额外依赖..."
    pip3 install httpx email-validator APScheduler --quiet 2>/dev/null || true
    
    echo -e "${GREEN}  ✓ 依赖安装完成${NC}"
    echo ""
}

# 配置Nginx
configure_nginx() {
    echo -e "${CYAN}▸ 配置Nginx...${NC}"
    
    # 加载域名配置
    if [ -f /data/wanyue-ai-customer/.env.install ]; then
        source /data/wanyue-ai-customer/.env.install
    else
        SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    fi
    
    # 检查Nginx是否安装
    if ! command -v nginx &> /dev/null; then
        echo -e "  • 安装Nginx..."
        apt-get update -qq
        apt-get install -y -qq nginx certbot python3-certbot-nginx >/dev/null 2>&1 || true
    fi
    
    # 创建Nginx配置
    echo -e "  • 创建Nginx配置..."
    
    if [ -n "$DOMAIN" ]; then
        # HTTPS配置
        cat > /etc/nginx/sites-available/wanyue-ai << EOF
server {
    listen 80;
    server_name $DOMAIN;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # 静态文件缓存
    location /static {
        alias /data/wanyue-ai-customer/app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
    else
        # HTTP配置（IP访问）
        cat > /etc/nginx/sites-available/wanyue-ai << EOF
server {
    listen 80;
    server_name $SERVER_IP;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
    }
}
EOF
    fi
    
    # 启用配置
    ln -sf /etc/nginx/sites-available/wanyue-ai /etc/nginx/sites-enabled/
    
    # 测试配置
    nginx -t && echo -e "  ✓ Nginx配置测试通过"
    
    # 重新加载Nginx
    systemctl reload nginx 2>/dev/null || nginx -s reload 2>/dev/null || true
    
    echo -e "${GREEN}  ✓ Nginx配置完成${NC}"
    echo ""
}

# 配置SSL证书（可选）
configure_ssl() {
    if [ -z "$DOMAIN" ]; then
        return
    fi
    
    echo -e "${CYAN}▸ 配置SSL证书（可选）...${NC}"
    echo ""
    echo -e "${YELLOW}是否为域名 ${DOMAIN} 配置HTTPS？${NC}"
    echo "  1) 使用Let's Encrypt免费SSL（推荐）"
    echo "  2) 使用已有SSL证书"
    echo "  3) 跳过，稍后手动配置"
    echo ""
    echo -ne "${GREEN}请输入选项 [1-3]: ${NC}"
    read SSL_CHOICE
    
    case $SSL_CHOICE in
        1)
            echo -e "  • 申请Let's Encrypt证书..."
            certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN 2>/dev/null || {
                echo -e "${YELLOW}  ⚠ SSL申请失败，请手动配置${NC}"
            }
            if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
                echo -e "  ✓ SSL证书配置成功"
                
                # 更新Nginx配置为HTTPS
                cat > /etc/nginx/sites-available/wanyue-ai << EOF
server {
    listen 80;
    server_name $DOMAIN;
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;
    
    ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_session_tickets off;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    location /static {
        alias /data/wanyue-ai-customer/app/static;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
EOF
                nginx -t && systemctl reload nginx
            fi
            ;;
        2)
            echo -e "${YELLOW}请将证书文件复制到以下位置：${NC}"
            echo "  • 证书: /etc/ssl/certs/wanyue-ai.crt"
            echo "  • 密钥: /etc/ssl/private/wanyue-ai.key"
            echo ""
            echo -e "${GREEN}配置完成后，请手动修改Nginx配置启用HTTPS${NC}"
            ;;
        3)
            echo -e "  ✓ 跳过SSL配置"
            ;;
    esac
    
    echo ""
}

# 初始化数据库
init_database() {
    echo -e "${CYAN}▸ 初始化数据库...${NC}"
    
    cd /data/wanyue-ai-customer
    
    # 运行数据库初始化
    echo -e "  • 创建数据库表..."
    python3 -c "
import sys
sys.path.insert(0, '/data/wanyue-ai-customer')
from app.core.database import init_db
from app.core.database import engine, Base
from app.models.user import *
Base.metadata.create_all(bind=engine)
print('Database initialized')
" 2>/dev/null || echo -e "  • 数据库已存在，跳过创建"
    
    # 初始化默认数据
    echo -e "  • 初始化默认数据..."
    python3 -c "
import sys
sys.path.insert(0, '/data/wanyue-ai-customer')
from app.core.database import SessionLocal, engine, Base
from app.models.user import *
from datetime import datetime

db = SessionLocal()

# 检查是否已有数据
if db.query(MembershipLevel).count() == 0:
    levels = [
        MembershipLevel(code='free', name='免费版', price=0, monthly_api_calls=100, max_knowledge_bases=1, max_documents=10, max_embed_configs=1, is_active=True, sort_order=1),
        MembershipLevel(code='basic', name='基础版', price=29, monthly_api_calls=1000, max_knowledge_bases=3, max_documents=100, max_embed_configs=3, is_active=True, sort_order=2),
        MembershipLevel(code='pro', name='专业版', price=99, monthly_api_calls=5000, max_knowledge_bases=10, max_documents=500, max_embed_configs=10, is_active=True, sort_order=3),
        MembershipLevel(code='enterprise', name='企业版', price=299, monthly_api_calls=20000, max_knowledge_bases=50, max_documents=2000, max_embed_configs=50, is_active=True, sort_order=4),
    ]
    for level in levels:
        db.add(level)

if db.query(TokenPackage).count() == 0:
    packages = [
        TokenPackage(name='体验包', token_amount=10, price=10, gift_amount=0, is_active=True, sort_order=1),
        TokenPackage(name='基础包', token_amount=50, price=45, gift_amount=5, is_active=True, sort_order=2),
        TokenPackage(name='进阶包', token_amount=100, price=85, gift_amount=15, is_active=True, sort_order=3),
        TokenPackage(name='高级包', token_amount=500, price=400, gift_amount=100, is_active=True, sort_order=4),
        TokenPackage(name='企业包', token_amount=1000, price=750, gift_amount=250, is_active=True, sort_order=5),
    ]
    for pkg in packages:
        db.add(pkg)

db.commit()
db.close()
print('Default data initialized')
" 2>/dev/null || echo -e "  • 默认数据已存在"
    
    echo -e "${GREEN}  ✓ 数据库初始化完成${NC}"
    echo ""
}

# 配置服务
configure_service() {
    echo -e "${CYAN}▸ 配置系统服务...${NC}"
    
    # 创建systemd服务文件
    echo -e "  • 创建系统服务..."
    cat > /etc/systemd/system/wanyue-ai.service << 'EOF'
[Unit]
Description=Wanyue AI Customer Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/data/wanyue-ai-customer
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd
    systemctl daemon-reload 2>/dev/null || true
    
    echo -e "${GREEN}  ✓ 系统服务配置完成${NC}"
    echo ""
}

# 启动服务
start_service() {
    echo -e "${CYAN}▸ 启动服务...${NC}"
    
    cd /data/wanyue-ai-customer
    
    # 杀掉旧进程
    pkill -f "uvicorn main:app" 2>/dev/null || true
    
    # 启动新进程
    nohup uvicorn main:app --host 0.0.0.0 --port 8000 > /data/wanyue-ai-customer/server.log 2>&1 &
    
    sleep 3
    
    # 检查是否启动成功
    if curl -s http://localhost:8000/ > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ 服务启动成功${NC}"
    else
        echo -e "${YELLOW}  ⚠ 服务启动中，请稍后访问${NC}"
    fi
    
    echo ""
}

# 完成信息
show_complete() {
    # 加载域名配置
    if [ -f /data/wanyue-ai-customer/.env.install ]; then
        source /data/wanyue-ai-customer/.env.install
    else
        DOMAIN=""
        SERVER_IP=$(curl -s https://api.ipify.org 2>/dev/null || curl -s https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
    fi
    
    # 判断访问协议
    if [ -n "$DOMAIN" ]; then
        # 检查是否有SSL
        if [ -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
            PROTOCOL="https"
        else
            PROTOCOL="http"
        fi
        ACCESS_URL="${PROTOCOL}://${DOMAIN}"
    else
        ACCESS_URL="http://${SERVER_IP}:8000"
    fi
    
    clear
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}                         ${YELLOW}安装完成！${NC}                                         ${GREEN}║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                              系统信息                                       ${BLUE}║${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}访问地址:${NC}    ${ACCESS_URL}"
    echo -e "${CYAN}管理后台:${NC}   ${ACCESS_URL}/admin"
    echo -e "${CYAN}文档地址:${NC}   ${ACCESS_URL}/docs"
    echo ""
    echo -e "${YELLOW}默认管理员账号:${NC}"
    echo -e "  • 邮箱: admin@wanyue.cn"
    echo -e "  • 密码: admin123456"
    echo ""
    echo -e "${RED}⚠ 请首次登录后立即修改默认密码！${NC}"
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}                              版权信息                                       ${BLUE}║${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}© 2026 亦梓科技有限公司 (Yizi Technology Co., Ltd.)${NC}"
    echo -e "${YELLOW}© 2026 万岳科技 (Wanyue Technology - 分公司)${NC}"
    echo -e "${GREEN}感谢您的使用！${NC}"
    echo ""
    echo -e "${CYAN}查看日志: tail -f /data/wanyue-ai-customer/server.log${NC}"
    echo -e "${CYAN}重启服务: systemctl restart wanyue-ai${NC}"
    echo ""
}

# 主函数
main() {
    show_copyright
    show_welcome
    check_system
    configure_domain
    install_dependencies
    init_database
    configure_nginx
    configure_ssl
    configure_service
    start_service
    
    # 复制工具箱到系统
    cp /data/wanyue-ai-customer/wanyue /usr/local/bin/wanyue
    chmod +x /usr/local/bin/wanyue
    
    show_complete
}

# 检查是否已安装
check_installed() {
    if [ -d /data/wanyue-ai-customer ] && [ -f /data/wanyue-ai-customer/wanyue ]; then
        return 0  # 已安装
    else
        return 1  # 未安装
    fi
}

# 首次安装菜单
show_first_install_menu() {
    while true; do
        echo ""
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo -e "${CYAN}                           初次设置                                         ${NC}"
        echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "  ${GREEN}1.${NC}  开始安装万岳AI客服系统"
        echo -e "  ${GREEN}0.${NC}  退出"
        echo ""
        echo -ne "${CYAN}请输入选项 [0-1]: ${NC}"
        read choice
        
        case $choice in
            1)
                main
                break
                ;;
            0)
                echo ""
                echo -e "${GREEN}感谢使用！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效选项${NC}"
                ;;
        esac
    done
}

# 执行主函数
if check_installed; then
    # 已安装，显示工具箱
    /usr/local/bin/wanyue
else
    # 未安装，先下载工具箱
    cp /data/wanyue-ai-customer/wanyue /usr/local/bin/wanyue 2>/dev/null || true
    chmod +x /usr/local/bin/wanyue 2>/dev/null || true
    show_first_install_menu
fi
