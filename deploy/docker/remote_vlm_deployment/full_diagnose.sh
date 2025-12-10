#!/bin/bash
######################################################################################################
# VSS 完整诊断脚本
######################################################################################################

echo "========================================"
echo "VSS 完整系统诊断"
echo "========================================"
echo ""

cd "$(dirname "$0")"

# 1. 容器状态
echo "1. 容器状态"
echo "----------------------------------------"
docker-compose ps
echo ""

# 2. GPU 状态
echo "2. GPU 状态"
echo "----------------------------------------"
docker-compose exec -T via-server nvidia-smi --query-gpu=index,name,utilization.gpu,memory.used,memory.total --format=csv,noheader 2>/dev/null || echo "❌ 无法访问 GPU"
echo ""

# 3. VLM 配置
echo "3. VLM 配置"
echo "----------------------------------------"
docker-compose exec -T via-server bash -c 'env | grep -E "VIA_VLM|VLM_BATCH|NUM_VLM|NUM_GPUS"' 2>/dev/null || echo "❌ 无法读取配置"
echo ""

# 4. 测试阿里云 API
echo "4. 测试阿里云 Qwen-VL API"
echo "----------------------------------------"
API_KEY="sk-97ef48ca4569402aba42b864f7a92782"
echo "测试连接..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-vl-plus",
    "messages": [{"role": "user", "content": [{"type": "text", "text": "hi"}]}],
    "max_tokens": 5
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ API 连接成功"
    echo "$BODY" | jq -r '.choices[0].message.content // "响应正常"' 2>/dev/null || echo "$BODY"
else
    echo "❌ API 调用失败 (HTTP $HTTP_CODE)"
    echo "$BODY"
fi
echo ""

# 5. 最近的错误
echo "5. 最近的错误日志"
echo "----------------------------------------"
docker-compose logs via-server --tail=200 | grep -i "error\|exception\|fail" | tail -10 || echo "✅ 未发现错误"
echo ""

# 6. Summarize 处理流程
echo "6. Summarize 处理流程"
echo "----------------------------------------"
docker-compose logs via-server | grep -E "Received summarize query|Triggering|decode|VLM processing|Chunk" | tail -20 || echo "⚠️  未发现处理日志"
echo ""

# 7. VLM 进程状态
echo "7. VLM 进程队列状态"
echo "----------------------------------------"
docker-compose logs via-server --tail=50 | grep "No items in queue" | tail -5 || echo "VLM 进程正在工作或未启动"
echo ""

# 8. 资产管理器
echo "8. 上传的视频"
echo "----------------------------------------"
docker-compose logs via-server | grep "Added file from path" | tail -3 || echo "⚠️  未发现上传的视频"
echo ""

echo "========================================"
echo "诊断完成"
echo "========================================"
echo ""
echo "请根据上述信息判断："
echo "- 如果 API 调用失败 → API Key 或网络问题"
echo "- 如果有错误日志 → 查看具体错误信息"
echo "- 如果没有处理日志 → 请求可能被静默丢弃"

