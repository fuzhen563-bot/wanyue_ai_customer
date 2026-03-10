#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
万岳AI客服系统 - 独立数据库初始化脚本
用于在没有加密代码的情况下初始化数据库
"""

import os
import sys

# 设置路径
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)

# 数据库配置
DB_PATH = os.path.join(script_dir, 'wanyue_ai.db')

def get_database_url():
    """获取数据库URL"""
    # 优先使用环境变量
    db_url = os.getenv('DATABASE_URL')
    if db_url:
        return db_url
    # 默认使用SQLite
    return f'sqlite:///{DB_PATH}'

def init_database():
    """初始化数据库"""
    from sqlalchemy import create_engine, Column, Integer, String, Float, Boolean, DateTime, Text, ForeignKey
    from sqlalchemy.ext.declarative import declarative_base
    from sqlalchemy.orm import sessionmaker, relationship
    from datetime import datetime
    
    print(f"数据库路径: {DB_PATH}")
    
    # 创建引擎
    engine = create_engine(get_database_url(), echo=False)
    Base = declarative_base()
    
    # 定义模型
    class User(Base):
        __tablename__ = 'users'
        
        id = Column(Integer, primary_key=True)
        email = Column(String(255), unique=True, nullable=False, index=True)
        username = Column(String(100), unique=True, nullable=False)
        hashed_password = Column(String(255), nullable=False)
        full_name = Column(String(100))
        is_active = Column(Boolean, default=True)
        is_superuser = Column(Boolean, default=False)
        membership_level_id = Column(Integer, ForeignKey('membership_levels.id'))
        api_calls_used = Column(Integer, default=0)
        api_calls_limit = Column(Integer, default=100)
        token_balance = Column(Integer, default=0)
        created_at = Column(DateTime, default=datetime.utcnow)
        updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    class MembershipLevel(Base):
        __tablename__ = 'membership_levels'
        
        id = Column(Integer, primary_key=True)
        code = Column(String(50), unique=True, nullable=False)
        name = Column(String(100), nullable=False)
        price = Column(Float, default=0)
        monthly_api_calls = Column(Integer, default=100)
        max_knowledge_bases = Column(Integer, default=1)
        max_documents = Column(Integer, default=10)
        max_embed_configs = Column(Integer, default=1)
        is_active = Column(Boolean, default=True)
        sort_order = Column(Integer, default=0)
    
    class TokenPackage(Base):
        __tablename__ = 'token_packages'
        
        id = Column(Integer, primary_key=True)
        name = Column(String(100), nullable=False)
        token_amount = Column(Integer, nullable=False)
        price = Column(Float, nullable=False)
        gift_amount = Column(Integer, default=0)
        is_active = Column(Boolean, default=True)
        sort_order = Column(Integer, default=0)
    
    class ChatSession(Base):
        __tablename__ = 'chat_sessions'
        
        id = Column(Integer, primary_key=True)
        user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
        session_id = Column(String(100), unique=True, nullable=False, index=True)
        customer_name = Column(String(100))
        customer_email = Column(String(255))
        status = Column(String(20), default='active')
        created_at = Column(DateTime, default=datetime.utcnow)
        updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    class ChatMessage(Base):
        __tablename__ = 'chat_messages'
        
        id = Column(Integer, primary_key=True)
        session_id = Column(Integer, ForeignKey('chat_sessions.id'), nullable=False)
        message_type = Column(String(20), nullable=False)  # user, assistant
        content = Column(Text, nullable=False)
        created_at = Column(DateTime, default=datetime.utcnow)
    
    class KnowledgeBase(Base):
        __tablename__ = 'knowledge_bases'
        
        id = Column(Integer, primary_key=True)
        user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
        name = Column(String(200), nullable=False)
        description = Column(Text)
        is_active = Column(Boolean, default=True)
        created_at = Column(DateTime, default=datetime.utcnow)
        updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    class Document(Base):
        __tablename__ = 'documents'
        
        id = Column(Integer, primary_key=True)
        knowledge_base_id = Column(Integer, ForeignKey('knowledge_bases.id'), nullable=False)
        filename = Column(String(255), nullable=False)
        file_path = Column(String(500))
        file_type = Column(String(50))
        file_size = Column(Integer)
        status = Column(String(20), default='pending')  # pending, processing, completed, failed
        chunk_count = Column(Integer, default=0)
        error_message = Column(Text)
        created_at = Column(DateTime, default=datetime.utcnow)
        updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    class EmbedConfig(Base):
        __tablename__ = 'embed_configs'
        
        id = Column(Integer, primary_key=True)
        user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
        name = Column(String(200), nullable=False)
        provider = Column(String(50), nullable=False)  # openai, azure, local
        model = Column(String(100))
        api_key = Column(String(500))
        api_base = Column(String(500))
        is_active = Column(Boolean, default=True)
        created_at = Column(DateTime, default=datetime.utcnow)
        updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    class APIKey(Base):
        __tablename__ = 'api_keys'
        
        id = Column(Integer, primary_key=True)
        user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
        key = Column(String(100), unique=True, nullable=False, index=True)
        name = Column(String(100))
        is_active = Column(Boolean, default=True)
        created_at = Column(DateTime, default=datetime.utcnow)
        last_used_at = Column(DateTime)
    
    class Order(Base):
        __tablename__ = 'orders'
        
        id = Column(Integer, primary_key=True)
        user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
        order_no = Column(String(100), unique=True, nullable=False, index=True)
        package_id = Column(Integer, ForeignKey('token_packages.id'))
        token_amount = Column(Integer, default=0)
        amount = Column(Float, default=0)
        payment_method = Column(String(50))
        status = Column(String(20), default='pending')  # pending, paid, cancelled, refunded
        paid_at = Column(DateTime)
        created_at = Column(DateTime, default=datetime.utcnow)
    
    # 创建表
    print("创建数据库表...")
    Base.metadata.create_all(bind=engine)
    print("✓ 数据库表创建成功")
    
    # 创建会话
    Session = sessionmaker(bind=engine)
    db = Session()
    
    try:
        # 初始化会员等级
        print("初始化会员等级...")
        if db.query(MembershipLevel).count() == 0:
            levels = [
                MembershipLevel(code='free', name='免费版', price=0, monthly_api_calls=100, 
                              max_knowledge_bases=1, max_documents=10, max_embed_configs=1, 
                              is_active=True, sort_order=1),
                MembershipLevel(code='basic', name='基础版', price=29, monthly_api_calls=1000, 
                              max_knowledge_bases=3, max_documents=100, max_embed_configs=3, 
                              is_active=True, sort_order=2),
                MembershipLevel(code='pro', name='专业版', price=99, monthly_api_calls=5000, 
                              max_knowledge_bases=10, max_documents=500, max_embed_configs=10, 
                              is_active=True, sort_order=3),
                MembershipLevel(code='enterprise', name='企业版', price=299, monthly_api_calls=20000, 
                              max_knowledge_bases=50, max_documents=2000, max_embed_configs=50, 
                              is_active=True, sort_order=4),
            ]
            for level in levels:
                db.add(level)
            db.commit()
            print("✓ 会员等级初始化成功")
        
        # 初始化Token套餐
        print("初始化Token套餐...")
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
            print("✓ Token套餐初始化成功")
        
        # 创建默认管理员
        print("创建默认管理员...")
        from passlib.context import CryptContext
        pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
        
        if db.query(User).count() == 0:
            # 获取免费会员等级ID
            free_level = db.query(MembershipLevel).filter(MembershipLevel.code == 'free').first()
            
            admin = User(
                email='admin@wanyue.cn',
                username='admin',
                hashed_password=pwd_context.hash('admin123456'),
                full_name='管理员',
                is_active=True,
                is_superuser=True,
                membership_level_id=free_level.id if free_level else None,
                api_calls_limit=free_level.monthly_api_calls if free_level else 100,
                token_balance=0
            )
            db.add(admin)
            db.commit()
            print("✓ 默认管理员创建成功")
            print("  邮箱: admin@wanyue.cn")
            print("  密码: admin123456")
        
        print("\n" + "="*50)
        print("数据库初始化完成！")
        print("="*50)
        
    except Exception as e:
        print(f"初始化失败: {e}")
        db.rollback()
        raise
    finally:
        db.close()

if __name__ == '__main__':
    print("万岳AI客服系统 - 数据库初始化")
    print("="*50)
    
    # 检查Python版本
    if sys.version_info < (3, 8):
        print("错误: 需要Python 3.8或更高版本")
        sys.exit(1)
    
    # 检查并安装依赖
    print("\n检查依赖...")
    required_packages = ['sqlalchemy', 'passlib', 'bcrypt']
    missing = []
    for pkg in required_packages:
        try:
            __import__(pkg)
        except ImportError:
            missing.append(pkg)
    
    if missing:
        print(f"安装缺失的依赖: {', '.join(missing)}")
        os.system(f"pip3 install {' '.join(missing)}")
    
    # 初始化数据库
    init_database()
