#!/bin/bash
######################################################################################################
# VSS 启动脚本（带 OpenAI Embedding 补丁）
######################################################################################################

set -e

echo ""
echo "================================================"
echo "VSS 启动（带 Milvus + Embedding 补丁）"
echo "================================================"

# 1. 清理 CA-RAG 字节码缓存（确保使用挂载的修复文件）
echo "🧹 清理 CA-RAG 字节码缓存..."
find /usr/local/lib/python3.12/dist-packages/vss_ctx_rag/ -name "*.pyc" -delete 2>/dev/null || true
find /usr/local/lib/python3.12/dist-packages/vss_ctx_rag/ -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
echo "  ✓ CA-RAG 将使用挂载的 Milvus 修复文件："
echo "    - foundation_rag/__init__.py (milvus-standalone)"
echo "    - aiq/utils.py (milvus-standalone, graph-db)"
echo ""

# 2. 检查并应用补丁
if [ -f /opt/nvidia/openai_embedding_patch.py ] && [ -f /opt/nvidia/milvus_connection_patch.py ]; then
    echo "✅ 发现补丁文件（Milvus + Embedding）"
    
    # 方法1：通过 PYTHONPATH
    export PYTHONPATH="/opt/nvidia:${PYTHONPATH:-}"
    echo "✅ 已设置 PYTHONPATH: $PYTHONPATH"
    
    # 方法2：创建 sitecustomize.py (如果权限允许)
    SITE_PACKAGES=$(python3 -c "import site; print(site.getsitepackages()[0])" 2>/dev/null || echo "/usr/local/lib/python3.12/site-packages")
    SITECUSTOMIZE="$SITE_PACKAGES/sitecustomize.py"
    
    if [ -w "$SITE_PACKAGES" ]; then
        cat > "$SITECUSTOMIZE" << 'EOF'
# VSS Milvus + Embedding 补丁
# 这个文件会在任何 Python 程序启动时自动加载

import sys
sys.path.insert(0, '/opt/nvidia')

try:
    # 1. 加载 Milvus 连接补丁（优先）
    import milvus_connection_patch
    # 2. 加载 Embedding 补丁
    import openai_embedding_patch
    # 补丁会在导入时自动应用
except Exception as e:
    print(f"⚠️  补丁加载失败: {e}")
EOF
        echo "✅ sitecustomize.py 已创建: $SITECUSTOMIZE"
    else
        echo "⚠️  无法创建 sitecustomize.py（权限不足），将只使用 PYTHONPATH"
    fi
    
    # 方法3：在 Python 启动时强制导入
    cat > /tmp/vss_patch_loader.py << 'EOF'
import sys
import os
sys.path.insert(0, '/opt/nvidia')

# 强制加载补丁
try:
    import milvus_connection_patch
    print("✅ VSS Milvus 连接补丁已加载")
    import openai_embedding_patch
    print("✅ VSS Embedding 补丁已加载")
except Exception as e:
    print(f"❌ 补丁加载失败: {e}")
    import traceback
    traceback.print_exc()
EOF
    
    # 设置 Python 启动时自动执行
    export PYTHONSTARTUP=/tmp/vss_patch_loader.py
    echo "✅ 已设置 PYTHONSTARTUP"
    
else
    echo "ℹ️  未发现补丁文件，使用默认配置"
fi

echo ""
echo "启动 VSS 服务..."
echo "================================================"
echo ""

# 调用原始启动脚本
exec /opt/nvidia/via/start_via.sh "$@"
