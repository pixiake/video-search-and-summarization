#!/bin/bash
######################################################################################################
# 等待 Milvus 就绪
######################################################################################################

MILVUS_HOST="milvus-standalone"
MILVUS_PORT="9091"
MAX_WAIT=180  # 最多等待 180 秒

echo "========================================
等待 Milvus 启动完成...
========================================"

for i in $(seq 1 $MAX_WAIT); do
    if curl -s -f "http://${MILVUS_HOST}:${MILVUS_PORT}/healthz" > /dev/null 2>&1; then
        echo "✓ Milvus 已就绪！(耗时 ${i} 秒)"
        echo ""
        exit 0
    fi
    
    if [ $((i % 10)) -eq 0 ]; then
        echo "  等待中... (${i}/${MAX_WAIT}秒)"
    fi
    
    sleep 1
done

echo "✗ Milvus 启动超时（${MAX_WAIT}秒）"
echo "  将继续尝试启动 VSS，但 CA-RAG 可能无法正常工作"
echo ""
exit 0  # 返回 0 让容器继续启动


