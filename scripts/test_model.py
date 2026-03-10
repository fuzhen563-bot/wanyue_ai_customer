#!/usr/bin/env python3
"""测试 LLM 模型是否可用"""

import asyncio
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.llm_service import LLMService, LLM_PROVIDERS


def test_model(provider: str, api_key: str, model: str = None, base_url: str = None):
    """测试指定模型"""
    
    print(f"\n{'='*50}")
    print(f"测试模型: {provider}")
    if model:
        print(f"模型名称: {model}")
    print(f"{'='*50}\n")
    
    # 显示支持的提供商
    if provider not in LLM_PROVIDERS and provider != "custom":
        print(f"错误: 未知的提供商 '{provider}'")
        print(f"\n支持的提供商: {', '.join(LLM_PROVIDERS.keys())}")
        return
    
    async def run_test():
        service = LLMService(
            api_key=api_key,
            provider=provider,
            model=model,
            base_url=base_url
        )
        
        try:
            print("正在连接并测试...")
            result = await service.test_connection()
            
            if result["success"]:
                print(f"\n✅ 测试成功!")
                print(f"   模型: {result.get('model', 'N/A')}")
                return True
            else:
                print(f"\n❌ 测试失败!")
                print(f"   错误: {result.get('error', '未知错误')}")
                return False
        finally:
            await service.close()
    
    return asyncio.run(run_test())


def main():
    if len(sys.argv) < 3:
        print("用法: python test_model.py <provider> <api_key> [model] [base_url]")
        print("\n支持的提供商:")
        for key, value in LLM_PROVIDERS.items():
            print(f"  {key}: {value['name']} (默认模型: {value['default_model']})")
        print("\n示例:")
        print("  python test_model.py openai sk-xxx")
        print("  python test_model.py openai sk-xxx gpt-4o")
        print("  python test_model.py ollama '' llama2")
        print("  python test_model.py siliconflow sk-xxx Qwen/Qwen2-7B-Instruct")
        print("  python test_model.py qianwen sk-xxx qwen-plus")
        print("  python test_model.py zhipu sk-xxx glm-4-flash")
        sys.exit(1)
    
    provider = sys.argv[1]
    api_key = sys.argv[2]
    model = sys.argv[3] if len(sys.argv) > 3 else None
    base_url = sys.argv[4] if len(sys.argv) > 4 else None
    
    success = test_model(provider, api_key, model, base_url)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
