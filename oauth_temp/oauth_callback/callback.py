#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OAuth 回调处理模块
Python版本的OAuth回调处理，对应原始PHP的oauth_callback.php
支持Flask和Django框架
"""

import json
import time
import secrets
import hashlib
import os
import sys
from typing import Dict, Any, Optional, Tuple
from urllib.parse import urlencode, urlparse

# 尝试导入Flask（如果可用）
try:
    from flask import Flask, request, session, redirect, jsonify, make_response
    FLASK_AVAILABLE = True
except ImportError:
    FLASK_AVAILABLE = False

# 尝试导入Django（如果可用）
try:
    import django
    from django.http import JsonResponse, HttpResponseRedirect
    from django.conf import settings
    DJANGO_AVAILABLE = True
except ImportError:
    DJANGO_AVAILABLE = False

# 导入本地配置
from .config import (
    OAUTH_SERVER,
    OAUTH_CLIENT_ID,
    OAUTH_CLIENT_SECRET,
    OAUTH_REDIRECT_URI,
    DEBUG_MODE,
    debug_log,
    show_error
)


class OAuthCallbackHandler:
    """
    OAuth回调处理器
    处理OAuth授权码换取令牌和获取用户信息的完整流程
    """
    
    def __init__(self):
        self.oauth_server = OAUTH_SERVER
        self.client_id = OAUTH_CLIENT_ID
        self.client_secret = OAUTH_CLIENT_SECRET
        self.redirect_uri = OAUTH_REDIRECT_URI
        self.debug_mode = DEBUG_MODE
        
    def validate_callback_params(self, params: Dict[str, Any]) -> Tuple[bool, str]:
        """
        验证OAuth回调参数
        
        Args:
            params: URL查询参数
            
        Returns:
            (是否有效, 错误消息)
        """
        # 验证授权码
        if 'code' not in params:
            return False, '缺少授权码(code)参数'
            
        # 验证state参数
        if 'state' not in params:
            return False, '缺少state参数'
            
        return True, ''
    
    def validate_state(self, session_state: Optional[str], received_state: str) -> bool:
        """
        验证state参数防止CSRF攻击
        
        Args:
            session_state: session中存储的state
            received_state: URL中接收的state
            
        Returns:
            是否验证通过
        """
        if not session_state or session_state != received_state:
            return False
        return True
    
    def generate_state(self) -> str:
        """
        生成安全的state参数
        
        Returns:
            随机state字符串
        """
        return secrets.token_urlsafe(32)
    
    def generate_code_verifier(self) -> str:
        """
        生成PKCE代码验证器
        
        Returns:
            代码验证器字符串
        """
        return secrets.token_urlsafe(64)
    
    def generate_code_challenge(self, code_verifier: str) -> str:
        """
        生成PKCE代码挑战
        
        Args:
            code_verifier: 代码验证器
            
        Returns:
            代码挑战字符串
        """
        return hashlib.sha256(code_verifier.encode()).digest().hex()
    
    def exchange_code_for_token(self, code: str) -> Dict[str, Any]:
        """
        使用授权码换取访问令牌
        
        Args:
            code: OAuth授权码
            
        Returns:
            令牌信息字典
            
        Raises:
            Exception: 请求失败时抛出异常
        """
        import urllib.request
        import urllib.error
        
        token_url = f"{self.oauth_server}/oauth/token.php"
        
        token_data = {
            'grant_type': 'authorization_code',
            'code': code,
            'client_id': self.client_id,
            'client_secret': self.client_secret,
            'redirect_uri': self.redirect_uri
        }
        
        debug_log('发送token请求', {
            'url': token_url,
            'data': token_data
        })
        
        try:
            # 发送POST请求
            data = urlencode(token_data).encode('utf-8')
            req = urllib.request.Request(
                token_url, 
                data=data, 
                method='POST'
            )
            req.add_header('Content-Type', 'application/x-www-form-urlencoded')
            
            with urllib.request.urlopen(req, timeout=10) as response:
                token_response = response.read().decode('utf-8')
                http_code = response.status
                
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8') if e.fp else str(e)
            debug_log('token请求HTTP错误', {
                'http_code': e.code,
                'error': str(e),
                'response': error_body
            })
            raise Exception(f'Token请求失败: {e}')
        except Exception as e:
            debug_log('token请求异常', {'error': str(e)})
            raise Exception(f'Token请求失败: {e}')
        
        debug_log('token响应', {
            'http_code': http_code,
            'response': token_response
        })
        
        try:
            token_info = json.loads(token_response)
        except json.JSONDecodeError as e:
            raise Exception(f'响应格式错误: {e}')
        
        if 'error' in token_info:
            error_desc = token_info.get('error_description', '未知错误')
            raise Exception(f'获取访问令牌失败: {error_desc}')
            
        if 'access_token' not in token_info:
            raise Exception('响应中缺少access_token')
        
        debug_log('获取到access_token', {
            'token': token_info['access_token'][:20] + '...',
            'token_info': token_info
        })
        
        return token_info
    
    def get_user_info(self, access_token: str) -> Dict[str, Any]:
        """
        使用访问令牌获取用户信息
        
        Args:
            access_token: 访问令牌
            
        Returns:
            用户信息字典
            
        Raises:
            Exception: 请求失败时抛出异常
        """
        import urllib.request
        import urllib.error
        
        user_info_url = f"{self.oauth_server}/oauth/userinfo.php"
        
        debug_log('请求用户信息', {
            'url': user_info_url,
            'headers': f'Authorization: Bearer {access_token[:20]}...'
        })
        
        try:
            req = urllib.request.Request(user_info_url)
            req.add_header('Authorization', f'Bearer {access_token}')
            req.add_header('Accept', 'application/json')
            
            with urllib.request.urlopen(req, timeout=10) as response:
                user_info_response = response.read().decode('utf-8')
                http_code = response.status
                
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8') if e.fp else str(e)
            debug_log('用户信息请求HTTP错误', {
                'http_code': e.code,
                'error': str(e),
                'response': error_body
            })
            raise Exception(f'用户信息请求失败: {e}')
        except Exception as e:
            debug_log('用户信息请求异常', {'error': str(e)})
            raise Exception(f'用户信息请求失败: {e}')
        
        debug_log('用户信息响应', {
            'http_code': http_code,
            'response': user_info_response
        })
        
        try:
            user_info = json.loads(user_info_response)
        except json.JSONDecodeError as e:
            raise Exception(f'响应格式错误: {e}')
        
        if 'error' in user_info:
            error_desc = user_info.get('error_description', '未知错误')
            raise Exception(f'获取用户信息失败: {error_desc}')
            
        if 'uid' not in user_info:
            raise Exception('响应中缺少用户ID')
        
        debug_log('获取到用户信息', user_info)
        
        return user_info
    
    def handle_callback(self, params: Dict[str, Any], session_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        处理OAuth回调的完整流程
        
        Args:
            params: URL查询参数
            session_data: session数据字典
            
        Returns:
            包含结果和用户信息的字典
        """
        receive_time = time.time()
        
        # 1. 验证参数
        is_valid, error_msg = self.validate_callback_params(params)
        if not is_valid:
            debug_log('参数验证失败', params)
            return {
                'success': False,
                'error': error_msg,
                'redirect': './login.py'
            }
        
        code = params.get('code')
        state = params.get('state')
        
        debug_log('收到授权码', {
            'code': code,
            'state': state,
            'receive_time': receive_time
        })
        
        # 2. 验证state
        session_state = session_data.get('oauth_state')
        if not self.validate_state(session_state, state):
            debug_log('State验证失败', {
                'session_state': session_state,
                'get_state': state
            })
            return {
                'success': False,
                'error': 'State验证失败，可能遭受CSRF攻击',
                'redirect': './login.py'
            }
        
        try:
            # 3. 换取access_token
            token_info = self.exchange_code_for_token(code)
            access_token = token_info['access_token']
            
            # 4. 获取用户信息
            user_info = self.get_user_info(access_token)
            
            # 5. 准备返回数据
            result = {
                'success': True,
                'user': user_info,
                'access_token': access_token,
                'token_info': token_info,
                'login_time': int(receive_time),
                'redirect': './'
            }
            
            # 清理临时数据
            if 'oauth_state' in session_data:
                del session_data['oauth_state']
            
            # 计算总耗时
            total_time = time.time() - receive_time
            debug_log('登录完成', {
                'user_id': user_info.get('uid'),
                'username': user_info.get('username'),
                'total_time': f'{total_time}秒'
            })
            
            return result
            
        except Exception as e:
            debug_log('OAuth处理异常', {
                'message': str(e)
            })
            return {
                'success': False,
                'error': str(e),
                'redirect': './login.py'
            }


# Flask 集成
if FLASK_AVAILABLE:
    app = Flask(__name__)
    app.secret_key = os.environ.get('SECRET_KEY', secrets.token_hex(32))
    
    oauth_handler = OAuthCallbackHandler()
    
    @app.route('/oauth_callback.py')
    def oauth_callback():
        """Flask OAuth回调路由"""
        # 获取查询参数
        params = request.args.to_dict()
        
        # 获取session
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
            
            return redirect(result['redirect'])
        else:
            # 保存错误信息并重定向
            session['oauth_error'] = result['error']
            return redirect(result['redirect'])
    
    @app.route('/login.py')
    def login():
        """登录入口路由"""
        # 生成state
        state = oauth_handler.generate_state()
        session['oauth_state'] = state
        
        # 构建授权URL
        auth_url = f"{OAUTH_SERVER}/oauth/authorize.php"
        params = {
            'client_id': oauth_handler.client_id,
            'redirect_uri': oauth_handler.redirect_uri,
            'response_type': 'code',
            'state': state
        }
        
        full_auth_url = f"{auth_url}?{urlencode(params)}"
        return redirect(full_auth_url)


# 命令行测试
if __name__ == '__main__':
    print("=" * 60)
    print("OAuth Callback Handler - Python版本")
    print("=" * 60)
    print(f"OAuth服务器: {OAUTH_SERVER}")
    print(f"客户端ID: {OAUTH_CLIENT_ID}")
    print(f"回调地址: {OAUTH_REDIRECT_URI}")
    print(f"调试模式: {'开启' if DEBUG_MODE else '关闭'}")
    print("=" * 60)
    
    # 测试模式
    if len(sys.argv) > 1 and sys.argv[1] == '--test':
        print("\n运行测试模式...")
        
        handler = OAuthCallbackHandler()
        
        # 测试参数验证
        print("\n1. 测试参数验证:")
        valid, msg = handler.validate_callback_params({'code': 'test'})
        print(f"   - 缺少state: {msg}")
        
        valid, msg = handler.validate_callback_params({'state': 'test'})
        print(f"   - 缺少code: {msg}")
        
        valid, msg = handler.validate_callback_params({'code': 'test', 'state': 'test'})
        print(f"   - 完整参数: {'通过' if valid else msg}")
        
        # 测试state生成
        print("\n2. 测试state生成:")
        state1 = handler.generate_state()
        state2 = handler.generate_state()
        print(f"   - State 1: {state1[:20]}...")
        print(f"   - State 2: {state2[:20]}...")
        print(f"   - 唯一性: {'通过' if state1 != state2 else '失败'}")
        
        print("\n测试完成!")
    else:
        print("\n使用方法:")
        print("  1. 作为Flask应用运行: python -m oauth_callback.callback")
        print("  2. 运行测试: python -m oauth_callback.callback --test")
        print("  3. 集成到现有Flask项目")
        print("\n提示: 需要安装Flask: pip install flask")
        
        # 检查Flask是否可用
        if not FLASK_AVAILABLE:
            print("\n警告: Flask未安装，无法运行Web服务")
            print("安装Flask: pip install flask")
