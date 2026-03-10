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
git clone <你的仓库地址> wanyue-ai-customer
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

### 数据表结构

#### 1. users - 用户表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| email | String(255) | 邮箱（唯一） |
| username | String(100) | 用户名（唯一） |
| hashed_password | String(255) | 加密密码 |
| full_name | String(100) | 姓名 |
| role | String(20) | 角色：user/admin |
| is_active | Boolean | 是否激活 |
| balance | Float | 余额（元） |
| token_balance | Float | Token余额 |
| total_recharge | Float | 累计充值 |
| total_consume | Float | 累计消费 |
| phone | String(20) | 手机号 |
| company | String(200) | 公司 |
| title | String(100) | 职位 |
| website | String(500) | 网站 |
| bio | Text | 个人简介 |
| avatar_url | String(500) | 头像URL |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 2. api_keys - API密钥表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 用户ID |
| provider | String(50) | 提供商：openai/anthropic/ollama等 |
| key_name | String(100) | 密钥名称 |
| api_key | String(500) | API密钥（加密） |
| base_url | String(500) | 自定义API地址 |
| model_name | String(100) | 默认模型 |
| is_active | Boolean | 是否启用 |
| is_default | Boolean | 是否默认 |
| created_at | DateTime | 创建时间 |

#### 3. knowledge_bases - 知识库表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 所属用户ID |
| name | String(200) | 知识库名称 |
| description | Text | 描述 |
| embedding_model | String(100) | 嵌入模型 |
| chunk_size | Integer | 分段大小 |
| chunk_overlap | Integer | 分段重叠 |
| document_count | Integer | 文档数量 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 4. documents - 文档表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| knowledge_base_id | Integer | 知识库ID |
| filename | String(500) | 文件名 |
| file_type | String(50) | 文件类型 |
| file_size | Integer | 文件大小（字节） |
| content | Text | 提取的文本内容 |
| char_count | Integer | 字符数 |
| status | String(20) | 状态：pending/processing/completed/failed |
| error_message | Text | 错误信息 |
| created_at | DateTime | 创建时间 |

#### 5. embed_configs - 嵌入配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 用户ID |
| name | String(200) | 配置名称 |
| auth_code | String(100) | 授权码（唯一） |
| allowed_domains | Text | 允许的域名（逗号分隔） |
| welcome_message | String(500) | 欢迎语 |
| system_prompt | Text | 系统提示词 |
| theme_color | String(20) | 主题色 |
| position | String(20) | 位置：left/right |
| primary_knowledge_base_id | Integer | 主知识库ID |
| default_llm_provider | String(50) | 默认LLM提供商 |
| default_model | String(100) | 默认模型 |
| api_key_id | Integer | 用户API密钥ID |
| is_active | Boolean | 是否启用 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 6. chat_sessions - 对话会话表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 用户ID（可为空） |
| embed_config_id | Integer | 嵌入配置ID |
| session_key | String(100) | 会话标识（匿名） |
| visitor_info | String(500) | 访客信息（JSON） |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |
| message_count | Integer | 消息数 |

#### 7. chat_messages - 对话消息表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| session_id | Integer | 会话ID |
| role | String(20) | 角色：user/assistant |
| content | Text | 消息内容 |
| token_count | Integer | Token数量 |
| model_used | String(100) | 使用的模型 |
| created_at | DateTime | 创建时间 |

#### 8. membership_levels - 会员等级表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| name | String(50) | 等级名称 |
| code | String(20) | 等级代码：free/basic/pro/enterprise |
| price | Float | 月价格 |
| year_price | Float | 年价格 |
| max_knowledge_bases | Integer | 最大知识库数 |
| max_documents | Integer | 最大文档数 |
| max_document_size | Integer | 单个文档大小（MB） |
| max_embed_configs | Integer | 最大嵌入配置数 |
| monthly_free_tokens | Integer | 每月免费Token |
| allow_custom_llm | Boolean | 允许自定义LLM |
| allow_api_access | Boolean | 允许API访问 |
| is_active | Boolean | 是否启用 |
| sort_order | Integer | 排序 |
| created_at | DateTime | 创建时间 |

#### 9. user_memberships - 用户会员表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| user_id | Integer | 用户ID |
| level_id | Integer | 会员等级ID |
| start_date | DateTime | 开始时间 |
| end_date | DateTime | 结束时间 |
| is_active | Boolean | 是否有效 |
| tokens_used | Integer | 已使用Token |
| tokens_reset_at | DateTime | 重置时间 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 10. orders - 订单表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| order_no | String(50) | 订单号（唯一） |
| user_id | Integer | 用户ID |
| level_id | Integer | 会员等级ID |
| amount | Float | 金额 |
| pay_type | String(20) | 支付方式：wechat/alipay/epay/balance |
| status | String(20) | 状态：pending/paid/cancelled/refunded |
| order_type | String(20) | 类型：recharge/membership/token/consume |
| model_name | String(100) | 模型名称 |
| token_count | Integer | Token数量 |
| input_tokens | Integer | 输入Token |
| output_tokens | Integer | 输出Token |
| pay_time | DateTime | 支付时间 |
| created_at | DateTime | 创建时间 |

#### 11. token_packages - Token套餐表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| name | String(50) | 套餐名称 |
| token_amount | Integer | Token数量 |
| price | Float | 价格（元） |
| gift_amount | Integer | 赠送Token |
| is_active | Boolean | 是否启用 |
| sort_order | Integer | 排序 |
| created_at | DateTime | 创建时间 |

#### 12. payment_configs - 支付配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| alipay_enabled | Boolean | 支付宝启用 |
| alipay_app_id | String(50) | 支付宝AppID |
| alipay_private_key | String(500) | 支付宝私钥 |
| alipay_public_key | String(500) | 支付宝公钥 |
| alipay_notify_url | String(200) | 支付宝回调地址 |
| wechat_enabled | Boolean | 微信支付启用 |
| wechat_mch_id | String(50) | 微信商户号 |
| wechat_api_key | String(100) | 微信API密钥 |
| wechat_app_id | String(50) | 微信AppID |
| wechat_notify_url | String(200) | 微信回调地址 |
| epay_enabled | Boolean | 易支付启用 |
| epay_url | String(200) | 易支付地址 |
| epay_pid | String(50) | 易支付商户号 |
| epay_key | String(100) | 易支付密钥 |
| epay_notify_url | String(200) | 易支付回调地址 |
| is_active | Boolean | 是否启用 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 13. email_configs - 邮箱配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| smtp_host | String(100) | SMTP服务器 |
| smtp_port | Integer | SMTP端口 |
| smtp_user | String(100) | SMTP用户名 |
| smtp_password | String(100) | SMTP密码 |
| use_tls | Boolean | 是否使用TLS |
| from_email | String(100) | 发件人邮箱 |
| from_name | String(100) | 发件人名称 |
| notify_membership_expire_enabled | Boolean | 会员到期提醒启用 |
| notify_membership_expire_days | Integer | 提前提醒天数 |
| notify_membership_purchase_enabled | Boolean | 会员购买提醒启用 |
| notify_login_enabled | Boolean | 登录提醒启用 |
| notify_api_failure_enabled | Boolean | API失效提醒启用 |
| is_active | Boolean | 是否启用 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 14. email_templates - 邮件模板表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| template_code | String(50) | 模板代码（唯一） |
| template_name | String(100) | 模板名称 |
| subject | String(200) | 邮件主题 |
| content | Text | 邮件内容（HTML） |
| is_active | Boolean | 是否启用 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### 15. email_verify_codes - 邮箱验证码表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| email | String(255) | 邮箱 |
| code | String(6) | 验证码 |
| purpose | String(20) | 用途：register/change_email |
| expires_at | DateTime | 过期时间 |
| used | Boolean | 是否已使用 |
| created_at | DateTime | 创建时间 |

#### 16. llm_models - LLM模型配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Integer | 主键 |
| provider | String(50) | 提供商 |
| model_name | String(100) | 模型名称 |
| model_display_name | String(100) | 显示名称 |
| model_type | String(20) | 类型：chat/embedding |
| api_base_url | String(500) | API地址 |
| api_key | String(500) | API密钥（加密） |
| price_per_1k_input | Float | 输入价格（元/千Token） |
| price_per_1k_output | Float | 输出价格（元/千Token） |
| max_tokens | Integer | 最大Token数 |
| is_enabled | Boolean | 是否启用 |
| is_default | Boolean | 是否默认 |
| is_active | Boolean | 是否可用 |
| sort_order | Integer | 排序 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

---

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
