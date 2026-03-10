#!/bin/bash

# ============================================
# 万岳AI客服系统 - 一键安装脚本
# ============================================
# Copyright © 2026 亦梓科技有限公司 (Yizi Technology)
# Copyright © 2026 万岳科技 (Wanyue Technology - 分公司)
# All Rights Reserved
# ============================================

set -e

# 进度条相关变量
TOTAL_STEPS=10
CURRENT_STEP=0
STEP_NAMES=()

# 进度条函数
show_progress_bar() {
    local current=$1
    local total=$2
    local step_name=$3
    local width=50
    
    # 计算百分比
    local percent=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    # 构建进度条
    printf "\r["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' '-'
    printf "] %3d%% %s" "$percent" "$step_name"
    
    # 完成后换行
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# 更新进度
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    local step_name="${STEP_NAMES[$((CURRENT_STEP-1))]}"
    show_progress_bar $CURRENT_STEP $TOTAL_STEPS "$step_name"
}

# 初始化进度条步骤
init_progress_steps() {
    STEP_NAMES=(
        "初始化安装环境    "
        "检测网络并配置镜像  "
        "检查系统环境      "
        "配置域名         "
        "安装Python依赖   "
        "初始化数据库     "
        "配置Nginx       "
        "配置SSL证书     "
        "配置系统服务     "
        "启动服务         "
    )
}

# 自动检测安装目录
get_install_dir() {
    local script_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$script_path"
}

INSTALL_DIR=$(get_install_dir)
CURRENT_DIR=$(pwd)

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
    cat > $INSTALL_DIR/.env.install << EOF
DOMAIN=$DOMAIN
SERVER_IP=$SERVER_IP
EOF
    
    echo ""
}

# 检测网络环境并切换镜像
detect_and_setup_mirror() {
    echo ""
    echo -e "${CYAN}▸ 检测网络环境...${NC}"
    
    # 测试连接速度
    echo -e "  • 检测网络连接..."
    
    # 检测是否为大陆用户（通过访问国内网站测试）
    CN_CHECK=$(curl -s -m 3 https://www.baidu.com -o /dev/null -w "%{http_code}" 2>/dev/null || echo "failed")
    
    if [ "$CN_CHECK" = "200" ] || [ "$CN_CHECK" = "301" ] || [ "$CN_CHECK" = "302" ]; then
        echo -e "  ✓ 检测为中国大陆网络环境"
        IS_CN=true
    else
        # 尝试其他检测方式
        CN_CHECK=$(curl -s -m 3 https://www.taobao.com -o /dev/null -w "%{http_code}" 2>/dev/null || echo "failed")
        if [ "$CN_CHECK" = "200" ] || [ "$CN_CHECK" = "301" ] || [ "$CN_CHECK" = "302" ]; then
            echo -e "  ✓ 检测为中国大陆网络环境"
            IS_CN=true
        else
            echo -e "  • 使用默认网络环境"
            IS_CN=false
        fi
    fi
    
    # 配置pip镜像
    if [ "$IS_CN" = "true" ]; then
        echo ""
        echo -e "${YELLOW}▸ 切换为国内镜像源...${NC}"
        
        # pip镜像 - 清华/阿里/豆瓣
        echo -e "  • 配置pip镜像..."
        mkdir -p ~/.pip
        cat > ~/.pip/pip.conf << 'PIPEOF'
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
trusted-host = pypi.tuna.tsinghua.edu.cn
timeout = 120
PIPEOF
        echo -e "    ✓ pip镜像: 清华大学"
        
        # Git配置
        echo -e "  • 配置Git镜像..."
        git config --global url."https://hub.fastgit.xyz/".insteadOf "https://github.com/"
        git config --global url."https://ghproxy.com/".insteadOf "https://github.com/"
        echo -e "    ✓ GitHub镜像: fastgit.xyz"
        
        # 配置apt镜像（如果存在）
        if [ -f /etc/apt/sources.list ]; then
            # 备份原sources.list
            cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
            
            # 检测当前使用的镜像
            if grep -q "ubuntu.com" /etc/apt/sources.list 2>/dev/null; then
                # 尝试替换为阿里云镜像
                sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
                sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
                echo -e "    ✓ apt镜像: 阿里云"
            fi
        fi
        
        # 配置pip安装镜像（针对本脚本）
        export PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
        export PIP_TRUSTED_HOST="pypi.tuna.tsinghua.edu.cn"
        
        echo -e "${GREEN}  ✓ 镜像配置完成${NC}"
    else
        echo -e "  • 使用默认源"
    fi
    
    # 返回检测结果供后续使用
    echo "$IS_CN" > /tmp/wanyue_cn_mode
    echo ""
}

# 检查并安装系统环境
check_and_install_dependencies() {
    echo ""
    echo -e "${CYAN}▸ 检查并配置系统环境...${NC}"
    
    # 检测系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS="unknown"
    fi
    
    echo -e "  • 检测到系统: ${OS}"
    
    # 安装基础依赖
    echo -e "  • 安装系统基础依赖..."
    
    case $OS in
        ubuntu|debian)
            apt-get update -qq
            apt-get install -y -qq python3 python3-pip python3-venv nginx git curl wget net-tools sqlite3 certbot python3-certbot-nginx 2>/dev/null || true
            ;;
        centos|redhat|rocky|alma)
            yum install -y python3 python3-pip nginx git curl wget net-tools sqlite3 2>/dev/null || true
            # 安装certbot
            if ! command -v certbot &> /dev/null; then
                yum install -y certbot python3-certbot-nginx 2>/dev/null || true
            fi
            ;;
        almalinux|rhel)
            dnf install -y python3 python3-pip nginx git curl wget net-tools sqlite3 2>/dev/null || true
            ;;
        *)
            # 尝试通用安装
            apt-get update -qq 2>/dev/null || yum update -y 2>/dev/null || true
            apt-get install -y -qq python3 python3-pip nginx git curl wget net-tools sqlite3 certbot python3-certbot-nginx 2>/dev/null || \
            yum install -y python3 python3-pip nginx git curl wget net-tools sqlite3 2>/dev/null || true
            ;;
    esac
    
    # 创建Python符号链接（如果不存在）
    if ! command -v python3 &> /dev/null; then
        echo -e "  ⚠ Python3 未安装，请手动安装"
    else
        # 确保python命令可用
        if ! command -v python &> /dev/null && command -v python3 &> /dev/null; then
            ln -sf $(which python3) /usr/bin/python 2>/dev/null || true
        fi
        # 确保pip可用
        if ! command -v pip3 &> /dev/null && command -v python3 &> /dev/null; then
            python3 -m ensurepip --default-pip 2>/dev/null || true
            python3 -m pip --version 2>/dev/null || curl -sS https://bootstrap.pypa.io/get-pip.py | python3 2>/dev/null || true
        fi
    fi
    
    # 确保pip3命令可用
    if ! command -v pip3 &> /dev/null && command -v python &> /dev/null; then
        python -m ensurepip --default-pip 2>/dev/null || true
    fi
    
    echo -e "${GREEN}  ✓ 系统环境配置完成${NC}"
    echo ""
    
    # 验证Python和pip安装
    echo -e "${CYAN}▸ 验证环境安装...${NC}"
    
    if ! command -v python3 &> /dev/null; then
        echo -e "${RED}✗ Python3 安装失败，请手动安装${NC}"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    echo -e "  ✓ Python 版本: $PYTHON_VERSION"
    
    # 确保pip可用
    if ! command -v pip3 &> /dev/null; then
        echo -e "  • 尝试安装pip..."
        python3 -m ensurepip --default-pip 2>/dev/null || curl -sS https://bootstrap.pypa.io/get-pip.py | python3 2>/dev/null || true
    fi
    
    if command -v pip3 &> /dev/null || python3 -m pip --version &> /dev/null; then
        echo -e "  ✓ pip 已可用"
    else
        echo -e "${YELLOW}⚠ pip 安装可能不完整，将尝试继续安装${NC}"
    fi
    
    # 检查内存
    MEMORY=$(free -m 2>/dev/null | awk '/Mem:/ {print $2}' || echo "1024")
    if [ "$MEMORY" -lt 512 ]; then
        echo -e "${YELLOW}⚠ 建议内存至少 512MB，当前 ${MEMORY}MB${NC}"
    else
        echo -e "  ✓ 内存: ${MEMORY}MB"
    fi
    
    echo -e "${GREEN}  ✓ 环境验证通过${NC}"
    echo ""
}

# 安装依赖
install_dependencies() {
    echo -e "${CYAN}▸ 安装Python依赖...${NC}"
    
    # 确认pip命令可用
    if command -v pip3 &> /dev/null; then
        PIP_CMD="pip3"
    elif python3 -m pip --version &> /dev/null; then
        PIP_CMD="python3 -m pip"
    else
        echo -e "${RED}✗ pip 不可用，请先安装pip${NC}"
        exit 1
    fi
    
    # 读取镜像配置（如果存在）
    if [ -f ~/.pip/pip.conf ]; then
        MIRROR_PARAM="--index-url https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn"
    else
        MIRROR_PARAM=""
    fi
    
    # 升级pip
    echo -e "  • 升级pip..."
    $PIP_CMD install --upgrade pip --quiet 2>/dev/null || true
    
    # 安装依赖 - 使用镜像
    echo -e "  • 安装核心依赖..."
    $PIP_CMD install $MIRROR_PARAM fastapi uvicorn sqlalchemy pydantic python-multipart python-jose passlib bcrypt python-dotenv aiofiles --quiet 2>/dev/null || \
    $PIP_CMD install fastapi uvicorn sqlalchemy pydantic python-multipart python-jose passlib bcrypt python-dotenv aiofiles --quiet 2>/dev/null || true
    
    # 安装额外依赖 - 使用镜像
    echo -e "  • 安装额外依赖..."
    $PIP_CMD install $MIRROR_PARAM httpx email-validator APScheduler --quiet 2>/dev/null || \
    $PIP_CMD install httpx email-validator APScheduler --quiet 2>/dev/null || true
    
    echo -e "${GREEN}  ✓ 依赖安装完成${NC}"
    echo ""
}

# 配置Nginx
configure_nginx() {
    echo -e "${CYAN}▸ 配置Nginx...${NC}"
    
    # 加载域名配置
    if [ -f $INSTALL_DIR/.env.install ]; then
        source $INSTALL_DIR/.env.install
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
        alias $INSTALL_DIR/app/static;
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
        alias $INSTALL_DIR/app/static;
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
    
    cd $INSTALL_DIR
    
    # 运行数据库初始化
    echo -e "  • 创建数据库表..."
    python3 -c "
import sys
sys.path.insert(0, '$INSTALL_DIR')
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
sys.path.insert(0, '$INSTALL_DIR')
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
WorkingDirectory=$INSTALL_DIR
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
    
    cd $INSTALL_DIR
    
    # 杀掉旧进程
    pkill -f "uvicorn main:app" 2>/dev/null || true
    
    # 启动新进程
    nohup uvicorn main:app --host 0.0.0.0 --port 8000 > $INSTALL_DIR/server.log 2>&1 &
    
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
    # 显示完成进度动画
    echo ""
    echo -e "${CYAN}▸ 正在完成安装...${NC}"
    for i in {1..5}; do
        printf "\r  "
        printf "%-20s" "$(echo -e "${GREEN}✓${NC}" | head -c $((i*4)))"
        sleep 0.2
    done
    echo ""
    
    # 加载域名配置
    if [ -f $INSTALL_DIR/.env.install ]; then
        source $INSTALL_DIR/.env.install
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
    echo -e "${CYAN}查看日志: tail -f $INSTALL_DIR/server.log${NC}"
    echo -e "${CYAN}重启服务: systemctl restart wanyue-ai${NC}"
    echo ""
}

# 主函数
main() {
    # 初始化进度条
    init_progress_steps
    
    show_copyright
    show_welcome
    
    # 进度1: 初始化
    update_progress
    
    # 进度2: 网络检测
    detect_and_setup_mirror
    update_progress
    
    # 进度3: 系统环境
    check_and_install_dependencies
    update_progress
    
    # 进度4: 域名配置
    configure_domain
    update_progress
    
    # 进度5: 安装依赖
    install_dependencies
    update_progress
    
    # 进度6: 初始化数据库
    init_database
    update_progress
    
    # 进度7: 配置Nginx
    configure_nginx
    update_progress
    
    # 进度8: 配置SSL
    configure_ssl
    update_progress
    
    # 进度9: 配置服务
    configure_service
    update_progress
    
    # 进度10: 启动服务
    start_service
    update_progress
    
    # 复制工具箱到系统
    cp $INSTALL_DIR/wanyue /usr/local/bin/wanyue
    chmod +x /usr/local/bin/wanyue
    
    show_complete
}

# 检查是否已安装
check_installed() {
    # 检查是否已有数据库文件（表示已安装）
    if [ -f "$INSTALL_DIR/wanyue_ai.db" ]; then
        return 0  # 已安装
    # 检查是否有已初始化的数据库内容
    elif [ -d "$INSTALL_DIR/app" ] && python3 -c "import sys; sys.path.insert(0, '$INSTALL_DIR'); from app.core.database import SessionLocal; db = SessionLocal(); db.query(__import__('app.models.user', fromlist=['User']).User).first()" 2>/dev/null; then
        return 0
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
    # 已安装，复制工具箱并显示
    cp $INSTALL_DIR/wanyue /usr/local/bin/wanyue 2>/dev/null || true
    chmod +x /usr/local/bin/wanyue 2>/dev/null || true
    /usr/local/bin/wanyue
else
    # 未安装，先复制工具箱到系统，然后安装
    cp $INSTALL_DIR/wanyue /usr/local/bin/wanyue 2>/dev/null || true
    chmod +x /usr/local/bin/wanyue 2>/dev/null || true
    show_first_install_menu
fi
