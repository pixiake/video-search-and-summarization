#!/bin/bash
######################################################################################################
# VSS 补丁预加载脚本
# 在 VSS 主进程启动前，预先加载补丁到 Python 环境
######################################################################################################

set -e

echo "🔧 VSS 补丁预加载器 (Embedding + Milvus)"
echo "================================"

if [ ! -f /opt/nvidia/openai_embedding_patch.py ]; then
    echo "⚠️  Embedding 补丁文件不存在，跳过"
    exit 0
fi

if [ ! -f /opt/nvidia/milvus_connection_patch.py ]; then
    echo "⚠️  Milvus 补丁文件不存在，跳过"
    exit 0
fi

# 测试补丁是否能正常工作
python3 << 'PYTHON_TEST'
import sys
import os

# 添加补丁路径
sys.path.insert(0, '/opt/nvidia')

print("测试补丁加载...")

try:
    # 导入 Milvus 连接补丁（优先加载）
    print("\n1️⃣ 加载 Milvus 连接补丁...")
    import milvus_connection_patch
    
    # 导入 Embedding 补丁
    print("\n2️⃣ 加载 Embedding 补丁...")
    import openai_embedding_patch
    
    # 测试是否成功替换
    from langchain_nvidia_ai_endpoints.embeddings import NVIDIAEmbeddings
    
    # 检查类型
    print(f"✅ NVIDIAEmbeddings 类型: {NVIDIAEmbeddings}")
    print(f"✅ 模块: {NVIDIAEmbeddings.__module__}")
    
    # 尝试创建实例
    test_emb = NVIDIAEmbeddings(
        model=os.getenv('EMBEDDING_MODEL_NAME', 'test'),
        base_url=os.getenv('EMBEDDING_BASE_URL', 'http://test'),
        api_key=os.getenv('EMBEDDING_API_KEY', 'test')
    )
    
    if hasattr(test_emb, 'embeddings_url'):
        print(f"✅ Embedding URL: {test_emb.embeddings_url}")
        print("✅ 补丁测试成功！")
    else:
        print("❌ 补丁可能未正确应用")
        exit(1)
    
except Exception as e:
    print(f"❌ 补丁测试失败: {e}")
    import traceback
    traceback.print_exc()
    exit(1)

PYTHON_TEST

echo "================================"
echo ""

