#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Flask应用集成示例
展示如何在Flask应用中使用OAuth回调处理脚本
"""

import os
from flask import Flask, session, redirect, request, jsonify
from oauth_callback import OAuthCallbackHandler, is_logged_in, get_current_user, debug_log

# 创建Flask应用
app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-here')

# 初始化OAuth处理器
oauth_handler = OAuthCallbackHandler()


@app.route('/')
def index():
    """首页"""
    if is_logged_in(session):
        user = get_current_user(session)
        return f'''
        <!DOCTYPE html>
        <html>
        <head>
            <title>首页 - 已登录</title>
            <style>
                body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 50px auto; padding: 20px; }}
                .user-info {{ background: #d4edda; color: #155724; padding: 20px; border-radius: 5px; }}
                .btn {{ background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 5px; }}
                h1 {{ color: #333; }}
            </style>
        </head>
        <body>
            <h1>欢迎回来!</h1>
            <div class="user-info">
                <h2>用户信息</h2>
                <p><strong>用户ID:</strong> {user.get('uid', 'N/A')}</p>
                <p><strong>用户名:</strong> {user.get('username', 'N/A')}</p>
                <p><strong>邮箱:</strong> {user.get('email', 'N/A')}</p>
                <p><strong>登录时间:</strong> {user.get('login_time', 'N/A')}</p>
            </div>
            <br>
            <a href="/logout" class="btn" style="background: #dc3545;">退出登录</a>
            <a href="/api/user" class="btn">获取用户API</a>
        </body>
        </html>
        '''
    else:
        return '''
        <!DOCTYPE html>
        <html>
        <head>
            <title>首页 - 未登录</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; text-align: center; }
                .btn { background: #007bff; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; display: inline-block; font-size: 18px; }
            </style>
        </head>
        <body>
            <h1>欢迎访问</h1>
            <p>请先登录以继续</p>
            <br>
            <a href="/login" class="btn">OAuth登录</a>
        </body>
        </html>
        '''


@app.route('/login')
def login():
    """登录入口"""
    # 生成并保存state到session
    state = oauth_handler.generate_state()
    session['oauth_state'] = state
    
    # 记录调试信息
    debug_log('开始OAuth登录流程', {
        'state': state,
        'client_id': oauth_handler.client_id,
        'redirect_uri': oauth_handler.redirect_uri
    })
    
    # 构建授权URL
    from urllib.parse import urlencode
    auth_url = f"{oauth_handler.oauth_server}/oauth/authorize.php"
    params = {
        'client_id': oauth_handler.client_id,
        'redirect_uri': oauth_handler.redirect_uri,
        'response_type': 'code',
        'state': state
    }
    
    full_auth_url = f"{auth_url}?{urlencode(params)}"
    
    return redirect(full_auth_url)


@app.route('/oauth_callback')
def oauth_callback():
    """OAuth回调处理"""
    # 获取查询参数
    params = request.args.to_dict()
    
    # 准备session数据
    session_data = {
        'oauth_state': session.get('oauth_state')
    }
    
    # 处理回调
    result = oauth_handler.handle_callback(params, session_data)
    
    if result['success']:
        # 保存用户信息到session
        session['user'] = result['user']
        session['oauth_access_token'] = result['access_token']
        session['oauth_token_info'] = result['token_info']
        session['login_time'] = result['login_time']
        
        # 清理临时state
        session.pop('oauth_state', None)
        
        debug_log('用户登录成功', {
            'user_id': result['user'].get('uid'),
            'username': result['user'].get('username')
        })
        
        return redirect(result['redirect'])
    else:
        # 保存错误信息
        session['oauth_error'] = result['error']
        
        debug_log('用户登录失败', {
            'error': result['error']
        })
        
        return f'''
        <!DOCTYPE html>
        <html>
        <head>
            <title>登录失败</title>
            <style>
                body {{ font-family: Arial, sans-serif; max-width: 600px; margin: 50px auto; padding: 20px; }}
                .error {{ background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; }}
                .btn {{ background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; }}
            </style>
        </head>
        <body>
            <h2>登录失败</h2>
            <div class="error">
                <p><strong>错误信息:</strong> {result['error']}</p>
            </div>
            <br>
            <a href="/login" class="btn">重新登录</a>
            <a href="/" class="btn">返回首页</a>
        </body>
        </html>
        '''


@app.route('/logout')
def logout():
    """退出登录"""
    # 清理session
    user = session.get('user', {})
    debug_log('用户退出登录', {
        'user_id': user.get('uid'),
        'username': user.get('username')
    })
    
    session.clear()
    
    return redirect('/')


@app.route('/api/user')
def api_user():
    """获取当前用户信息API"""
    if not is_logged_in(session):
        return jsonify({
            'success': False,
            'error': '未登录'
        }), 401
    
    user = get_current_user(session)
    return jsonify({
        'success': True,
        'data': user
    })


@app.route('/api/user/token')
def api_token():
    """获取OAuth令牌信息"""
    if not is_logged_in(session):
        return jsonify({
            'success': False,
            'error': '未登录'
        }), 401
    
    token_info = session.get('oauth_token_info', {})
    
    # 不返回完整的access_token
    safe_token_info = {
        'token_type': token_info.get('token_type'),
        'expires_in': token_info.get('expires_in'),
        'refresh_token': token_info.get('refresh_token')[:20] + '...' if token_info.get('refresh_token') else None
    }
    
    return jsonify({
        'success': True,
        'data': safe_token_info
    })


if __name__ == '__main__':
    # 运行Flask应用
    print("=" * 60)
    print("Flask OAuth集成示例")
    print("=" * 60)
    print("访问地址: http://127.0.0.1:5000")
    print("=" * 60)
    
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )
