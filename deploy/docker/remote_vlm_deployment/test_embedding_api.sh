#!/bin/bash
######################################################################################################
# 测试 Embedding API 是否配置正确
######################################################################################################

set -e

echo "================================================"
echo "Embedding API 连接测试"
echo "================================================"

# 从 .env 或当前环境读取配置
if [ -f .env ]; then
    source .env
fi

# 或者手动设置
EMBEDDING_BASE_URL="${EMBEDDING_BASE_URL:-https://open.bigmodel.cn/api/paas/v4}"
EMBEDDING_API_KEY="${EMBEDDING_API_KEY:-your-api-key}"
EMBEDDING_MODEL="${EMBEDDING_MODEL_NAME:-embedding-3}"

echo "配置信息:"
echo "  Base URL: $EMBEDDING_BASE_URL"
echo "  Model: $EMBEDDING_MODEL"
echo "  API Key: ${EMBEDDING_API_KEY:0:20}..."
echo ""

echo "================================================"
echo "测试1: 直接拼接 /embeddings"
echo "================================================"

ENDPOINT="${EMBEDDING_BASE_URL}/embeddings"
echo "完整URL: $ENDPOINT"
echo ""

curl -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $EMBEDDING_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "测试文本",
    "model": "'"$EMBEDDING_MODEL"'"
  }' 2>&1 | head -20

echo ""
echo ""
echo "================================================"
echo "测试2: OpenAI 标准路径 (去掉v4，加v1)"
echo "================================================"

# 移除 /v4，测试是否应该用 /v1/embeddings
BASE_WITHOUT_VERSION=$(echo "$EMBEDDING_BASE_URL" | sed 's|/v[0-9]$||')
ENDPOINT2="${BASE_WITHOUT_VERSION}/v1/embeddings"
echo "完整URL: $ENDPOINT2"
echo ""

curl -X POST "$ENDPOINT2" \
  -H "Authorization: Bearer $EMBEDDING_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "input": "测试文本",
    "model": "'"$EMBEDDING_MODEL"'"
  }' 2>&1 | head -20

echo ""
echo ""
echo "================================================"
echo "结果分析"
echo "================================================"
echo "✅ 如果看到 'embedding' 或 'data' 字段 = 成功"
echo "❌ 如果看到 404 错误 = URL 路径错误"
echo "❌ 如果看到 401/403 = API Key 错误"
echo "❌ 如果看到 Connection refused = 网络问题"
echo ""
echo "请根据上面哪个测试成功，来确定正确的配置！"

