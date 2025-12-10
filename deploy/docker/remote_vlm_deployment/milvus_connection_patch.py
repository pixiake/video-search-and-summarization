#!/usr/bin/env python3
"""
Milvus 连接补丁
强制将所有 Milvus 连接地址从 localhost 改为 milvus-standalone
"""
import os
import sys

def patch_milvus_connection():
    """在所有可能的位置强制修正 Milvus 连接"""
    
    print("=" * 60)
    print("🔧 Milvus 连接补丁加载中...")
    print("=" * 60)
    
    # 1. 强制设置环境变量（注意：port 必须是字符串类型）
    os.environ["MILVUS_DB_HOST"] = "milvus-standalone"
    os.environ["MILVUS_DB_GRPC_PORT"] = "19530"
    print(f"✓ 环境变量已设置: MILVUS_DB_HOST={os.environ['MILVUS_DB_HOST']}")
    print(f"✓ 环境变量已设置: MILVUS_DB_GRPC_PORT={os.environ['MILVUS_DB_GRPC_PORT']}")
    
    # 2. Monkey patch pymilvus 的默认连接参数
    try:
        import pymilvus
        from pymilvus import connections
        
        # 保存原始的 connect 方法
        original_connect = connections.connect
        
        def patched_connect(alias="default", **kwargs):
            """修补后的 connect 方法，强制使用正确的 host"""
            # 如果 host 是 localhost，强制改为 milvus-standalone
            if "host" in kwargs:
                if kwargs["host"] in ["localhost", "127.0.0.1", "0.0.0.0"]:
                    print(f"🔧 拦截到 localhost 连接，修改为: milvus-standalone:19530")
                    kwargs["host"] = "milvus-standalone"
                    # pymilvus 的 port 参数可以是 int 或 str，但保持为 int
                    kwargs["port"] = kwargs.get("port", 19530)
            else:
                # 如果没有指定 host，使用正确的地址
                kwargs["host"] = "milvus-standalone"
                kwargs["port"] = kwargs.get("port", 19530)
                print(f"🔧 未指定 host，设置为: milvus-standalone:19530")
            
            print(f"✓ Milvus 连接参数: host={kwargs.get('host')}, port={kwargs.get('port')}")
            return original_connect(alias=alias, **kwargs)
        
        # 替换 connect 方法
        connections.connect = patched_connect
        print("✓ pymilvus.connections.connect 已打补丁")
        
    except ImportError:
        print("⚠ pymilvus 未安装，跳过")
    
    # 3. Patch CA-RAG 的 Milvus 初始化
    try:
        # 等待 CA-RAG 模块加载后再 patch
        import sys
        from types import ModuleType
        
        class MilvusHostPatcher:
            """自动拦截 CA-RAG 的 Milvus 配置"""
            
            def __init__(self):
                self.original_import = __builtins__.__import__
                __builtins__.__import__ = self.patched_import
            
            def patched_import(self, name, *args, **kwargs):
                """拦截导入，patch Milvus 配置"""
                module = self.original_import(name, *args, **kwargs)
                
                # 如果导入的是 CA-RAG 相关模块
                if "ca_rag" in name or "carag" in name:
                    self._patch_module_milvus_config(module)
                
                return module
            
            def _patch_module_milvus_config(self, module):
                """递归 patch 模块中所有 Milvus 配置"""
                if not isinstance(module, ModuleType):
                    return
                
                for attr_name in dir(module):
                    try:
                        attr = getattr(module, attr_name)
                        
                        # Patch 字典配置
                        if isinstance(attr, dict):
                            self._patch_dict_milvus_config(attr)
                        
                        # Patch 类的属性
                        if hasattr(attr, "__dict__"):
                            self._patch_dict_milvus_config(attr.__dict__)
                    except:
                        pass
            
            def _patch_dict_milvus_config(self, config):
                """递归 patch 字典中的 Milvus 配置"""
                if not isinstance(config, dict):
                    return
                
                # 修正 host
                if "host" in config:
                    if config["host"] in ["localhost", "127.0.0.1", "0.0.0.0"]:
                        print(f"🔧 发现 localhost 配置，修改为: milvus-standalone")
                        config["host"] = "milvus-standalone"
                
                # 修正 port（注意：CA-RAG 的 MilvusDBConfig 要求 port 是字符串）
                if "port" in config and config.get("host") == "milvus-standalone":
                    if config["port"] not in ["19530", 19530]:
                        config["port"] = "19530"
                    elif isinstance(config["port"], int):
                        config["port"] = str(config["port"])
                
                # 递归处理嵌套字典
                for key, value in config.items():
                    if isinstance(value, dict):
                        self._patch_dict_milvus_config(value)
                    elif isinstance(value, list):
                        for item in value:
                            if isinstance(item, dict):
                                self._patch_dict_milvus_config(item)
        
        # 启动 Patcher
        patcher = MilvusHostPatcher()
        print("✓ CA-RAG Milvus 配置拦截器已启动")
        
    except Exception as e:
        print(f"⚠ CA-RAG 拦截器启动失败: {e}")
    
    print("=" * 60)
    print("🎉 Milvus 连接补丁加载完成！")
    print("=" * 60)

# 自动执行 patch
patch_milvus_connection()

