#!/bin/bash
######################################################################################################
# 在容器内查找 CA-RAG 库的位置和配置
######################################################################################################

echo "========================================
查找 CA-RAG 库位置...
========================================"

# 查找 CA-RAG Python 包
echo -e "\n🔍 查找 CA-RAG Python 包:"
find /opt/nvidia -name "*ca_rag*" -o -name "*carag*" 2>/dev/null | head -20

echo -e "\n🔍 查找 site-packages 中的 CA-RAG:"
python3 -c "import sys; print('\n'.join(sys.path))" | while read path; do
    if [ -d "$path" ]; then
        find "$path" -maxdepth 2 -name "*ca_rag*" -o -name "*carag*" 2>/dev/null
    fi
done

echo -e "\n🔍 查找包含 'localhost:19530' 的文件:"
grep -r "localhost.*19530" /opt/nvidia 2>/dev/null | head -10

echo -e "\n🔍 查找包含 'localhost' 和 'milvus' 的配置文件:"
find /opt/nvidia -name "*.yaml" -o -name "*.yml" -o -name "*.conf" 2>/dev/null | xargs grep -l "localhost" 2>/dev/null | head -10

echo -e "\n🔍 检查 CA-RAG 导入路径:"
python3 -c "
try:
    import ca_rag
    print(f'CA-RAG 位置: {ca_rag.__file__}')
    print(f'CA-RAG 版本: {ca_rag.__version__ if hasattr(ca_rag, \"__version__\") else \"未知\"}')
except ImportError as e:
    print(f'无法导入 ca_rag: {e}')

try:
    from ca_rag import config
    print(f'CA-RAG config 位置: {config.__file__}')
except:
    pass
" 2>&1

echo -e "\n🔍 检查 Python 环境中加载的 CA-RAG 模块:"
python3 << 'PYEOF'
import sys
import os

# 尝试导入并检查
try:
    import ca_rag
    print(f"\n✓ CA-RAG 包位置: {ca_rag.__file__}")
    
    # 列出 CA-RAG 目录内容
    ca_rag_dir = os.path.dirname(ca_rag.__file__)
    print(f"\n📂 CA-RAG 目录内容:")
    for root, dirs, files in os.walk(ca_rag_dir):
        level = root.replace(ca_rag_dir, '').count(os.sep)
        indent = ' ' * 2 * level
        print(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 2 * (level + 1)
        for file in files[:10]:  # 限制每个目录最多显示10个文件
            print(f'{subindent}{file}')
        if level > 2:  # 限制深度
            break
except ImportError as e:
    print(f"✗ 无法导入 CA-RAG: {e}")
PYEOF

echo -e "\n========================================"
echo "完成！"
echo "========================================"

