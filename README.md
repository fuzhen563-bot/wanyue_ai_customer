# 万岳AI智能客服系统

<p align="center">
  <img src="https://img.shields.io/badge/Python-3.8+-blue.svg" alt="Python">
  <img src="https://img.shields.io/badge/FastAPI-0.100+-green.svg" alt="FastAPI">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License">
</p>

一个功能完善的AI客服系统，支持多LLM提供商、知识库管理、网站嵌入、会员系统、Token套餐、支付集成等功能。

## 功能特性

- 🤖 **多LLM支持**: OpenAI、Anthropic Claude、Ollama、硅基流动、通义千问、智谱AI
- 📚 **知识库管理**: 支持PDF、TXT、MD、DOCX等格式文档上传，向量检索
- 💬 **网站嵌入**: 一键嵌入到任意网站作为AI客服
- 👥 **用户管理**: 完整的用户系统和会员等级
- 💳 **支付集成**: 支付宝、微信支付、易支付
- 🪙 **Token套餐**: Token充值套餐，支持购买Token包
- 📊 **收入统计**: 完整的收入统计报表
- 📧 **邮件通知**: 会员购买、到期提醒等邮件通知
- ⚙️ **工具箱**: 服务管理、域名配置、一键修复等运维功能

## 系统要求

- Python 3.8+
- Nginx (用于反向代理和HTTPS)
- 1GB+ 内存
- Linux系统 (推荐Ubuntu 20.04+)

---

## 一键安装教程

### 方式一：使用工具箱安装

```bash
# 1. 下载安装脚本
cd /data
git clone https://github.com/fuzhen563-bot/wanyue_ai_customer.git

cd wanyue-ai-customer

# 2. 运行安装脚本
bash install.sh
```

### 安装过程

1. 显示版权信息
2. 选择域名配置（可选）：
   - 直接使用IP地址
   - 使用域名（自动配置Let's Encrypt SSL）
   - 仅配置HTTP
3. 自动安装Python依赖
4. 初始化数据库
5. 配置Nginx
6. 申请SSL证书（可选）
7. 启动服务

### 安装完成

- 访问地址：`http://服务器IP:8000` 或 `https://你的域名`
- 管理后台：`/admin`
- 默认管理员：`admin@wanyue.cn` / `admin123456`

### 工具箱使用

安装完成后，工具箱会自动复制到系统路径，可以直接运行：

```bash
wanyue
```

或者从任意目录调用：

```bash
/usr/local/bin/wanyue
```

工具箱支持任意安装目录，会自动检测安装路径。

工具箱功能：
1. 系统状态检测
2. 更换域名
3. 一键修复
4. 重启服务
5. 查看日志
6. 服务管理
7. 数据库维护
8. 重新安装
9. 一键卸载

---

## 手动安装教程

### 1. 环境准备

```bash
# 更新系统
apt update && apt upgrade -y

# 安装Python和pip
apt install -y python3 python3-pip python3-venv

# 安装Nginx
apt install -y nginx

# 安装其他依赖
apt install -y git curl netstat-nat
```

### 2. 下载程序

```bash
cd /data
git clone <你的仓库地址> wanyue-ai-customer
cd wanyue-ai-customer
```

### 3. 创建虚拟环境

```bash
python3 -m venv venv
source venv/bin/activate
```

### 4. 安装依赖

```bash
pip install --upgrade pip
pip install fastapi uvicorn sqlalchemy pydantic python-multipart python-jose passlib bcrypt python-dotenv aiofiles httpx email-validator APScheduler
```

### 5. 初始化数据库

```bash
cd /data/wanyue-ai-customer
python3 -c "
from app.core.database import engine, Base
from app.models.user import *
Base.metadata.create_all(bind=engine)
print('数据库初始化完成')
"
```

### 6. 配置Nginx

创建Nginx配置文件：

```bash
cat > /etc/nginx/sites-available/wanyue-ai << 'EOF'
server {
    listen 80;
    server_name 你的域名;  # 或使用IP地址

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /static {
        alias /data/wanyue-ai-customer/app/static;
        expires 30d;
    }
}
EOF

# 启用配置
ln -s /etc/nginx/sites-available/wanyue-ai /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

### 7. 启动服务

```bash
cd /data/wanyue-ai-customer
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &
```

### 8. 配置SSL（可选）

使用Let's Encrypt免费SSL：

```bash
# 安装certbot
apt install -y certbot python3-certbot-nginx

# 申请证书
certbot --nginx -d 你的域名 --non-interactive --agree-tos --email your@email.com
```

---

## 目录结构

```
wanyue-ai-customer/
├── main.py                    # 应用入口
├── install.sh                 # 一键安装脚本
├── wanyue                     # 工具箱脚本
├── requirements.txt           # 依赖列表
├── README.md                  # 说明文档
├── wanyue_ai.db              # SQLite数据库
├── app/
│   ├── __init__.py
│   ├── main.py              # FastAPI应用实例
│   ├── config.py            # 应用配置
│   ├── api/                 # API路由
│   │   ├── __init__.py
│   │   ├── admin.py         # 管理后台API
│   │   ├── auth.py          # 认证登录
│   │   ├── chat.py          # 对话接口
│   │   ├── embed.py         # 嵌入配置API
│   │   ├── knowledge.py     # 知识库API
│   │   ├── membership.py    # 会员与支付API
│   │   ├── user.py          # 用户中心API
│   │   ├── monitor.py       # 系统监控API
│   │   └── oauth.py         # OAuth第三方登录
│   ├── core/                 # 核心模块
│   │   ├── __init__.py
│   │   ├── config.py        # 配置管理
│   │   ├── database.py      # 数据库连接
│   │   └── security.py      # 安全工具
│   ├── models/              # 数据模型
│   │   ├── __init__.py
│   │   ├── user.py          # 用户及所有业务模型
│   │   └── oauth.py         # OAuth模型
│   ├── schemas/             # Pydantic模型
│   ├── services/            # 业务服务
│   │   ├── __init__.py
│   │   ├── llm.py          # LLM调用服务
│   │   ├── knowledge.py     # 知识库服务
│   │   ├── payment.py      # 支付服务
│   │   └── email.py         # 邮件服务
│   ├── static/              # 静态资源
│   │   ├── css/            # 样式文件
│   │   ├── js/              # JavaScript文件
│   │   └── widget/         # 嵌入客服widget
│   └── templates/          # HTML模板
│       ├── auth.html       # 登录注册页面
│       ├── chat.html       # 对话页面
│       ├── embed.html      # 嵌入配置页面
│       ├── knowledge.html  # 知识库管理页面
│       ├── user.html       # 用户中心页面
│       ├── admin.html      # 管理后台页面
│       └── widget.html     # 客服widget页面
└── scripts/                # 脚本工具
```

---

## 详细功能说明

### 1. 用户系统

| 功能 | 说明 |
|------|------|
| 用户注册/登录 | 支持邮箱注册、密码登录 |
| OAuth登录 | 支持第三方账号登录（开发中） |
| 用户资料 | 头像、昵称、公司、职位等个人信息 |
| 会员等级 | 免费版、基础版、专业版、企业版 |
| 余额管理 | 余额充值、消费记录 |
| Token余额 | Token充值、使用统计 |

### 2. 模型配置

| 功能 | 说明 |
|------|------|
| 多提供商支持 | OpenAI、Anthropic Claude、Ollama、硅基流动、通义千问、智谱AI |
| API密钥管理 | 用户可添加自己的API密钥 |
| 自定义模型 | 支持自定义API地址和模型名称 |
| 管理员模型 | 管理员可配置系统模型及定价 |
| Token计费 | 按实际使用Token数计费 |

### 3. 知识库

| 功能 | 说明 |
|------|------|
| 文档上传 | 支持PDF、TXT、MD、DOCX格式 |
| 向量存储 | 自动将文档转为向量存储 |
| 语义检索 | 基于向量相似度检索 |
| 文档管理 | 查看、删除已上传文档 |
| 配置灵活 | 可设置分段大小、重叠度 |

### 4. 网站嵌入

| 功能 | 说明 |
|------|------|
| 嵌入配置 | 创建多个嵌入配置 |
| 授权码 | 每个配置有唯一的授权码 |
| 域名白名单 | 限制可嵌入的域名 |
| 自定义外观 | 主题色、位置、欢迎语 |
| 系统提示词 | 自定义AI客服角色 |
| 代码生成 | 一键生成嵌入代码 |

### 5. 会员系统

| 功能 | 说明 |
|------|------|
| 会员等级 | 免费/基础/专业/企业四级 |
| 等级权限 | 按等级控制知识库数、文档数等 |
| 会员购买 | 月付/年付套餐 |
| 续费管理 | 会员到期自动提醒 |

### 6. 支付系统

| 功能 | 说明 |
|------|------|
| 支付宝 | 扫码支付 |
| 微信支付 | 扫码支付 |
| 易支付 | 第三方支付聚合 |
| 余额支付 | 账户余额支付 |
| Token套餐 | 购买Token包 |

### 7. 邮件通知

| 功能 | 说明 |
|------|------|
| SMTP配置 | 支持任意SMTP服务器 |
| 会员开通 | 购买成功通知 |
| 会员到期 | 到期前提醒 |
| 登录提醒 | 异地登录通知 |
| API失效 | API密钥失效提醒 |

### 8. 管理后台

| 功能 | 说明 |
|------|------|
| 用户管理 | 查看、编辑、禁用用户 |
| 模型配置 | 系统模型及定价管理 |
| 知识库管理 | 查看所有知识库 |
| 订单管理 | 查看所有订单 |
| 收入统计 | 收入报表、分析图表 |
| 系统配置 | 支付、邮件等配置 |

---

## 数据库说明

### 数据库类型
- 默认：SQLite (`wanyue_ai.db`)
- 可切换：MySQL、PostgreSQL

## API接口说明

### 认证相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/auth/register | POST | 用户注册 |
| /api/auth/login | POST | 用户登录 |
| /api/auth/logout | POST | 退出登录 |
| /api/auth/me | GET | 获取当前用户 |

### 用户相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/user/profile | GET/POST | 用户资料 |
| /api/user/balance | GET | 获取余额 |
| /api/user/recharge | POST | 充值 |
| /api/user/token-balance | GET | Token余额 |

### 对话相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/chat/completions | POST | 对话（非流式） |
| /api/chat/stream | POST | 对话（流式） |
| /api/chat/history | GET | 对话历史 |
| /api/chat/session | GET | 获取会话 |

### 嵌入相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/embed/create | POST | 创建嵌入配置 |
| /api/embed/list | GET | 嵌入配置列表 |
| /api/embed/update | POST | 更新嵌入配置 |
| /api/embed/delete | DELETE | 删除嵌入配置 |
| /api/embed/code | GET | 获取嵌入代码 |
| /api/embed/chat | POST | 嵌入对话接口 |

### 知识库相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/knowledge/list | GET | 知识库列表 |
| /api/knowledge/create | POST | 创建知识库 |
| /api/knowledge/update | POST | 更新知识库 |
| /api/knowledge/delete | DELETE | 删除知识库 |
| /api/knowledge/upload | POST | 上传文档 |
| /api/knowledge/search | POST | 搜索 |

### 会员相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/membership/levels | GET | 会员等级列表 |
| /api/membership/buy | POST | 购买会员 |
| /api/membership/my | GET | 我的会员 |
| /api/membership/token-packages | GET | Token套餐列表 |
| /api/membership/buy-token | POST | 购买Token |

### 支付相关

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/payment/create-order | POST | 创建订单 |
| /api/payment/pay | POST | 支付 |
| /api/payment/notify | POST | 支付回调 |
| /api/payment/history | GET | 订单历史 |

### 管理后台

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/admin/users | GET | 用户列表 |
| /api/admin/users/{id} | GET/POST | 用户详情 |
| /api/admin/models | GET/POST | 模型配置 |
| /api/admin/orders | GET | 订单列表 |
| /api/admin/stats | GET | 统计数据 |
| /api/admin/payment-config | GET/POST | 支付配置 |
| /api/admin/email-config | GET/POST | 邮件配置 |

---

## 常见问题

### Q: 如何添加LLM API密钥？
A: 管理员登录后进入"模型配置"页面，配置相应的API密钥。

### Q: 如何嵌入到网站？
A: 创建嵌入配置后，点击"获取代码"按钮，将生成的代码添加到您的网站HTML中。

### Q: 支持哪些LLM提供商？
A: 目前支持：OpenAI、Anthropic Claude、Ollama、硅基流动、阿里云通义千问、智谱AI。

### Q: 如何配置支付？
A: 管理员登录后进入"支付配置"页面，填写支付宝/微信/易支付信息。

### Q: Token套餐和余额的区别？
A: Token套餐用于购买Token数量，用户使用管理员配置的模型时会扣除Token余额。余额用于其他付费功能。

---

## 技术栈

- **后端**: FastAPI + SQLAlchemy
- **数据库**: SQLite (可切换MySQL/PostgreSQL)
- **前端**: HTML + JavaScript (原生)
- **LLM**: OpenAI API 兼容接口
- **Web服务器**: Nginx

---

## 版权声明

```
© 2026 亦梓科技有限公司 (Yizi Technology Co., Ltd.)
© 2026 万岳科技 (Wanyue Technology - 分公司)

版权所有，侵权必究

未经授权，禁止以下行为：
- 反编译或逆向工程
- 未经授权的商业使用
- 删除或修改版权信息
- 再分发或转让本软件
```

---

## 技术支持

如遇问题，请联系技术支持。
