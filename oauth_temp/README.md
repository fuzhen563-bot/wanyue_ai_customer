# OAuth Callback Python Package

Python版本的OAuth回调处理包，将PHP的OAuth实现移植到Python。

## 功能特性

- 完整的OAuth 2.0授权码流程支持
- State验证防止CSRF攻击
- PKCE支持（可选）
- Flask框架集成
- Django框架支持（可选）
- 完整的调试日志功能
- 与PHP版本完全对应的API设计

## 安装

### 使用pip安装

```bash
pip install oauth-callback
```

### 从源码安装

```bash
# 克隆或下载源码后
cd oauth-callback-package
pip install -e .
```

### 手动安装依赖

```bash
pip install -r requirements.txt
```

## 快速开始

### 1. 基本配置

```python
from oauth_callback import (
    OAUTH_SERVER,
    OAUTH_CLIENT_ID,
    OAUTH_CLIENT_SECRET,
    OAUTH_REDIRECT_URI,
    OAuthCallbackHandler
)

# 或通过环境变量配置
import os
os.environ['OAUTH_SERVER'] = 'http://your-oauth-server.com'
os.environ['OAUTH_CLIENT_ID'] = 'your-client-id'
os.environ['OAUTH_CLIENT_SECRET'] = 'your-client-secret'
os.environ['OAUTH_REDIRECT_URI'] = 'http://your-site.com/oauth_callback'
```

### 2. Flask集成示例

```python
from flask import Flask, session, redirect, request
from oauth_callback import OAuthCallbackHandler, is_logged_in, get_current_user
import os

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key')

oauth_handler = OAuthCallbackHandler()

@app.route('/')
def index():
    if is_logged_in(session):
        user = get_current_user(session)
        return f'<h1>欢迎, {user.get("username")}!</h1>'
    return '<a href="/login">登录</a>'

@app.route('/login')
def login():
    state = oauth_handler.generate_state()
    session['oauth_state'] = state
    
    from urllib.parse import urlencode
    auth_url = f"{oauth_handler.oauth_server}/oauth/authorize.php"
    params = {
        'client_id': oauth_handler.client_id,
        'redirect_uri': oauth_handler.redirect_uri,
        'response_type': 'code',
        'state': state
    }
    return redirect(f"{auth_url}?{urlencode(params)}")

@app.route('/oauth_callback')
def oauth_callback():
    params = request.args.to_dict()
    session_data = {'oauth_state': session.get('oauth_state')}
    
    result = oauth_handler.handle_callback(params, session_data)
    
    if result['success']:
        session['user'] = result['user']
        session['oauth_access_token'] = result['access_token']
        session['oauth_token_info'] = result['token_info']
        session.pop('oauth_state', None)
        return redirect('/')
    else:
        return f'登录失败: {result["error"]}'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### 3. 直接使用OAuthCallbackHandler

```python
from oauth_callback import OAuthCallbackHandler

handler = OAuthCallbackHandler()

# 处理OAuth回调
params = {
    'code': 'authorization-code-from-oauth-server',
    'state': 'state-saved-in-session'
}
session_data = {'oauth_state': 'state-from-session'}

result = handler.handle_callback(params, session_data)

if result['success']:
    user = result['user']
    access_token = result['access_token']
    print(f"登录成功: {user.get('username')}")
else:
    print(f"登录失败: {result['error']}")
```

## 配置说明

### 环境变量配置

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| OAUTH_SERVER | OAuth服务器地址 | http://account |
| OAUTH_CLIENT_ID | 客户端ID | (从config.php移植) |
| OAUTH_CLIENT_SECRET | 客户端密钥 | (从config.php移植) |
| OAUTH_REDIRECT_URI | 回调地址 | http://test/oauth_callback.py |
| DEBUG_MODE | 调试模式 | true |

### 配置优先级

1. 环境变量（最高优先级）
2. 代码中的默认值

## API参考

### OAuthCallbackHandler

核心处理器类，提供OAuth回调的完整处理流程。

#### 方法

- `validate_callback_params(params)` - 验证回调参数
- `validate_state(session_state, received_state)` - 验证state防止CSRF
- `generate_state()` - 生成安全的state参数
- `exchange_code_for_token(code)` - 使用授权码换取token
- `get_user_info(access_token)` - 获取用户信息
- `handle_callback(params, session_data)` - 处理完整回调流程

### 辅助函数

- `is_logged_in(session)` - 检查用户是否已登录
- `get_current_user(session)` - 获取当前用户信息
- `safe_redirect(response, url)` - 安全重定向
- `show_error(message, request, session)` - 显示错误页面

## 调试

启用调试模式：

```python
import os
os.environ['DEBUG_MODE'] = 'true'
```

或在代码中：

```python
from oauth_callback import DEBUG_MODE, debug_log
DEBUG_MODE = True
debug_log('调试信息', {'key': 'value'})
```

## 目录结构

```
oauth-callback-package/
├── oauth_callback/
│   ├── __init__.py      # 包入口
│   ├── config.py        # 配置模块
│   └── callback.py      # 回调处理模块
├── setup.py             # 安装脚本
├── requirements.txt     # 依赖列表
└── README.md            # 说明文档
```

## 依赖

- Python 3.7+
- Flask 2.0+（Web框架支持）

## 许可证

MIT License

## 更新日志

### v1.0.0
- 初始版本
- 完整的OAuth 2.0授权码流程
- Flask集成支持
- 与PHP版本功能对应
