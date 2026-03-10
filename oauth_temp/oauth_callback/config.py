#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OAuth 配置文件
Python版本的OAuth配置，对应原始PHP的config.php
"""

import os
from typing import Optional, Dict, Any

# OAuth服务器配置
OAUTH_SERVER = os.environ.get('OAUTH_SERVER', 'http://account')
OAUTH_CLIENT_ID = os.environ.get('OAUTH_CLIENT_ID', 'e5a45a62b695197f6ff08f00bf6d5bf3')
OAUTH_CLIENT_SECRET = os.environ.get('OAUTH_CLIENT_SECRET', '43be95e26aa9a5b1f4ac7f015ee921b4')
OAUTH_REDIRECT_URI = os.environ.get('OAUTH_REDIRECT_URI', 'http://test/oauth_callback.py')

# 调试模式
DEBUG_MODE = os.environ.get('DEBUG_MODE', 'true').lower() == 'true'


def debug_log(message: str, data: Any = None) -> None:
    """
    调试日志函数
    
    Args:
        message: 日志消息
        data: 附加的调试数据
    """
    if DEBUG_MODE:
        print(f"[OAuth Debug] {message}")
        if data:
            print(f"[OAuth Data] {data}")


def is_logged_in(session) -> bool:
    """
    检查用户是否已登录
    
    Args:
        session: Flask/Django session对象
    
    Returns:
        bool: 是否已登录
    """
    return 'user' in session and session.get('user')


def get_current_user(session) -> Optional[Dict[str, Any]]:
    """
    获取当前登录用户信息
    
    Args:
        session: Flask/Django session对象
    
    Returns:
        用户信息字典，如果未登录返回None
    """
    if is_logged_in(session):
        return session.get('user')
    return None


def safe_redirect(response, url: str) -> Any:
    """
    安全重定向
    
    Args:
        response: Flask response对象或Django HttpResponseRedirect
        url: 重定向URL
    
    Returns:
        重定向响应对象
    """
    return response.redirect(url)


def show_error(message: str, request=None, session=None) -> str:
    """
    显示错误页面
    
    Args:
        message: 错误消息
        request: 请求对象（可选）
        session: session对象（可选）
    
    Returns:
        HTML错误页面字符串
    """
    import datetime
    
    current_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    session_status = '已启用' if session else '未启用'
    login_status = '已登录' if session and is_logged_in(session) else '未登录'
    request_uri = request.uri if request else 'N/A'
    
    html = f'''<!DOCTYPE html>
<html>
<head>
    <title>错误 - 第三方站点</title>
    <style>
        body {{ font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }}
        .error {{ background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        .info {{ background: #d1ecf1; color: #0c5460; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        .btn {{ background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; }}
    </style>
</head>
<body>
    <h2>错误提示</h2>
    <div class="error">{message}</div>
    <div class="info">
        <h3>调试信息：</h3>
        <p>当前时间：{current_time}</p>
        <p>Session状态：{session_status}</p>
        <p>用户登录状态：{login_status}</p>
        <p>当前URL：{request_uri}</p>
    </div>
    <a href="./" class="btn">返回首页</a>
    <a href="./login.py" class="btn">重新登录</a>
</body>
</html>'''
    return html
