#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OAuth Python Package
PHP OAuth配置的Python移植版本
"""

__version__ = "1.0.0"
__author__ = "Developer"

from .config import (
    OAUTH_SERVER,
    OAUTH_CLIENT_ID,
    OAUTH_CLIENT_SECRET,
    OAUTH_REDIRECT_URI,
    DEBUG_MODE,
    debug_log,
    is_logged_in,
    get_current_user,
    safe_redirect,
    show_error
)

from .callback import OAuthCallbackHandler

__all__ = [
    'OAUTH_SERVER',
    'OAUTH_CLIENT_ID',
    'OAUTH_CLIENT_SECRET',
    'OAUTH_REDIRECT_URI',
    'DEBUG_MODE',
    'debug_log',
    'is_logged_in',
    'get_current_user',
    'safe_redirect',
    'show_error',
    'OAuthCallbackHandler',
]
