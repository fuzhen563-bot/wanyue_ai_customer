#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OAuth Python Package Setup Script
"""

from setuptools import setup, find_packages

# 读取README
try:
    with open('README.md', 'r', encoding='utf-8') as f:
        long_description = f.read()
except:
    long_description = 'Python OAuth callback handler'

setup(
    name='oauth-callback',
    version='1.0.0',
    description='Python OAuth callback handler - PHP to Python port',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Developer',
    author_email='developer@example.com',
    url='https://github.com/example/oauth-callback',
    packages=find_packages(),
    install_requires=[
        'flask>=2.0.0',
    ],
    extras_require={
        'dev': [
            'pytest>=7.0.0',
            'pytest-cov>=4.0.0',
        ],
    },
    python_requires='>=3.7',
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
    ],
    keywords='oauth authentication callback flask django',
    entry_points={
        'console_scripts': [
            'oauth-callback=oauth_callback.callback:main',
        ],
    },
)
