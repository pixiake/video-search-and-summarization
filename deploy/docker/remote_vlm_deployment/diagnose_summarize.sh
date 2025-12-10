#!/bin/bash
######################################################################################################
# VSS Summarize 故障诊断脚本
######################################################################################################

set -e

echo "================================================"
echo "VSS Summarize 故障诊断"
echo "================================================"
echo ""

# 1. 检查容器状态
echo "1. 检查容器状态..."
docker-compose ps via-server
echo ""

# 2. 检查 VLM 配置
echo "2. 检查 VLM 配置..."
docker-compose exec -T via-server bash -c 'env | grep VIA_VLM' || echo "无法获取 VLM 配置"
echo ""

# 3. 测试阿里云 API
echo "3. 测试阿里云 Qwen-VL API..."
VLM_KEY=$(docker-compose exec -T via-server bash -c 'echo $VIA_VLM_API_KEY' | tr -d '\r')
VLM_ENDPOINT=$(docker-compose exec -T via-server bash -c 'echo $VIA_VLM_ENDPOINT' | tr -d '\r')

if [ -n "$VLM_KEY" ]; then
    echo "API Endpoint: $VLM_ENDPOINT"
    echo "API Key: ${VLM_KEY:0:20}..."
    echo ""
    echo "测试调用..."
    
    curl -s -X POST "${VLM_ENDPOINT}/chat/completions" \
      -H "Authorization: Bearer ${VLM_KEY}" \
      -H "Content-Type: application/json" \
      -d '{
        "model": "qwen-vl-plus",
        "messages": [
          {
            "role": "user",
            "content": [
              {"type": "text", "text": "这是测试"}
            ]
          }
        ],
        "max_tokens": 10
      }' | jq -r '.error.message // .choices[0].message.content // "连接成功"' || echo "❌ API 调用失败"
else
    echo "❌ 无法获取 VLM API Key"
fi

echo ""
echo ""

# 4. 检查最近的错误日志
echo "4. 检查最近的错误日志..."
docker-compose logs via-server --tail=100 | grep -i "error\|exception\|fail\|timeout" | tail -20 || echo "✅ 未发现明显错误"
echo ""

# 5. 检查 VLM 处理日志
echo "5. 检查 VLM 相关日志..."
docker-compose logs via-server --tail=100 | grep -i "vlm\|qwen\|decode\|chunk" | tail -20 || echo "⚠️  未发现 VLM 处理日志（可能还未开始）"
echo ""

echo "================================================"
echo "诊断完成"
echo "================================================"
echo ""
echo "下一步操作："
echo "1. 如果看到 API 调用失败，检查阿里云 API Key 是否有效"
echo "2. 如果没有 VLM 处理日志，查看完整日志: docker-compose logs -f via-server"
echo "3. 重新点击页面上的 Summarize，观察日志输出"

