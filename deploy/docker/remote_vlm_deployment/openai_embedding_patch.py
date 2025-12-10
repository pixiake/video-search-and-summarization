#!/usr/bin/env python3
"""
OpenAI-Compatible Embedding Patch for VSS
==========================================

这个补丁通过 monkey patching 的方式，让 VSS 可以使用任何 OpenAI-compatible 的 Embedding API。
特别支持智谱AI等使用非标准版本号（如 /v4 而不是 /v1）的服务。
"""

import sys
import os
import logging
import requests

logger = logging.getLogger(__name__)


def patch_nvidia_embeddings():
    """
    Monkey patch: 将 NVIDIA embeddings 替换为支持任意 API 的实现
    """
    try:
        # 检查是否配置了非 NVIDIA 的 embedding
        embedding_base_url = os.getenv('EMBEDDING_BASE_URL', '')
        if not embedding_base_url or 'nvidia.com' in embedding_base_url:
            logger.info("使用 NVIDIA embedding，跳过补丁")
            return False
        
        logger.info("=" * 70)
        logger.info("🔧 检测到非 NVIDIA embedding 配置")
        logger.info(f"   Base URL: {embedding_base_url}")
        logger.info("   应用自定义 embedding 适配器...")
        logger.info("=" * 70)
        
        # 创建自定义的 Embedding 类
        from langchain_core.embeddings import Embeddings
        
        class UniversalEmbeddings(Embeddings):
            """
            通用的 Embedding 客户端
            直接使用 HTTP 请求，兼容任何 OpenAI-style API
            """
            def __init__(self, model=None, base_url=None, api_key=None, **kwargs):
                self.model = model or os.getenv('EMBEDDING_MODEL_NAME', 'embedding-3')
                self.base_url = base_url or os.getenv('EMBEDDING_BASE_URL')
                self.api_key = api_key or os.getenv('EMBEDDING_API_KEY', 'not-needed')
                
                # 确保 base_url 格式正确
                if self.base_url and not self.base_url.endswith('/'):
                    self.base_url += '/'
                
                # 构建完整的 embeddings endpoint
                self.embeddings_url = f"{self.base_url}embeddings"
                
                logger.info(f"✅ 初始化通用 Embedding 客户端:")
                logger.info(f"   Model: {self.model}")
                logger.info(f"   Embeddings URL: {self.embeddings_url}")
                
            def embed_documents(self, texts):
                """批量生成文档 embeddings"""
                return self._get_embeddings(texts)
            
            def embed_query(self, text):
                """生成单个查询的 embedding"""
                return self._get_embeddings([text])[0]
            
            def _get_embeddings(self, texts):
                """调用 API 获取 embeddings"""
                headers = {
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.api_key}"
                }
                
                payload = {
                    "input": texts,
                    "model": self.model
                }
                
                try:
                    response = requests.post(
                        self.embeddings_url,
                        headers=headers,
                        json=payload,
                        timeout=30
                    )
                    response.raise_for_status()
                    
                    result = response.json()
                    
                    # 提取 embeddings（兼容不同的响应格式）
                    if 'data' in result:
                        # 标准 OpenAI 格式
                        embeddings = [item['embedding'] for item in result['data']]
                    elif 'embeddings' in result:
                        # 某些服务的格式
                        embeddings = result['embeddings']
                    else:
                        raise ValueError(f"无法解析响应格式: {result.keys()}")
                    
                    logger.debug(f"成功获取 {len(embeddings)} 个 embeddings，维度={len(embeddings[0])}")
                    return embeddings
                    
                except requests.exceptions.RequestException as e:
                    logger.error(f"Embedding API 调用失败: {e}")
                    logger.error(f"URL: {self.embeddings_url}")
                    logger.error(f"Payload: {payload}")
                    raise
        
        # 创建假的 langchain_nvidia_ai_endpoints 模块
        from types import ModuleType
        fake_nvidia_module = ModuleType('langchain_nvidia_ai_endpoints')
        fake_embeddings_module = ModuleType('langchain_nvidia_ai_endpoints.embeddings')
        
        # 注入我们的实现
        fake_embeddings_module.NVIDIAEmbeddings = UniversalEmbeddings
        fake_nvidia_module.embeddings = fake_embeddings_module
        
        # 替换系统模块
        sys.modules['langchain_nvidia_ai_endpoints'] = fake_nvidia_module
        sys.modules['langchain_nvidia_ai_endpoints.embeddings'] = fake_embeddings_module
        
        logger.info("✅ 通用 embedding 适配器已成功应用")
        logger.info("=" * 70)
        return True
        
    except Exception as e:
        logger.error(f"❌ 补丁应用失败: {e}", exc_info=True)
        logger.warning("   系统将尝试使用默认配置")
        return False


def apply_all_patches():
    """应用所有补丁"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s | %(levelname)s | %(name)s | %(message)s'
    )
    
    logger.info("")
    logger.info("=" * 70)
    logger.info("VSS Universal Embedding 补丁系统")
    logger.info("=" * 70)
    
    # 应用 embedding 补丁
    success = patch_nvidia_embeddings()
    
    if success:
        logger.info("✅ 补丁已成功加载")
    else:
        logger.info("ℹ️  使用默认配置（未应用补丁）")
    
    logger.info("=" * 70)
    logger.info("")
    
    return success


# 自动应用补丁（当模块被导入时）
if __name__ != "__main__":
    apply_all_patches()

# 如果直接运行，测试补丁
if __name__ == "__main__":
    apply_all_patches()
    
    # 测试导入
    try:
        from langchain_nvidia_ai_endpoints.embeddings import NVIDIAEmbeddings
        print("✅ 测试成功：可以导入 NVIDIAEmbeddings（已被替换）")
        
        # 尝试初始化
        emb = NVIDIAEmbeddings(
            model="embedding-3",
            base_url="https://open.bigmodel.cn/api/paas/v4",
            api_key="test-key"
        )
        print(f"✅ 测试成功：embedding 实例已创建")
        print(f"   类型: {type(emb)}")
        print(f"   URL: {emb.embeddings_url}")
    except Exception as e:
        print(f"❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
