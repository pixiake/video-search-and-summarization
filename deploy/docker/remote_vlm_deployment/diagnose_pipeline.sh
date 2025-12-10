#!/bin/bash
######################################################################################################
# VSS Pipeline 精准诊断
######################################################################################################

echo "========================================"
echo "VSS Pipeline 流程诊断"
echo "========================================"
echo ""

cd "$(dirname "$0")"

# 1. 查找 summarize 请求
echo "1. Summarize 请求"
echo "----------------------------------------"
LAST_QUERY=$(docker-compose logs via-server --tail=500 | grep "Received summarize query" | tail -1)
if [ -z "$LAST_QUERY" ]; then
    echo "❌ 未发现 summarize 请求"
    exit 1
else
    echo "$LAST_QUERY"
    # 提取视频ID
    VIDEO_ID=$(echo "$LAST_QUERY" | grep -oP 'id - \K[a-f0-9-]+' | head -1)
    echo "📹 视频ID: $VIDEO_ID"
fi
echo ""

# 2. 检查是否触发了 query
echo "2. 是否触发了 _trigger_query"
echo "----------------------------------------"
TRIGGER_LOG=$(docker-compose logs via-server --tail=500 | grep "Triggering oldest queued query")
if [ -z "$TRIGGER_LOG" ]; then
    echo "❌ 未触发 _trigger_query - 问题在 query() 方法或 CA-RAG 初始化"
    echo ""
    echo "检查 CA-RAG 相关日志："
    docker-compose logs via-server --tail=500 | grep -E "context manager|CA-RAG|ctx_mgr|reset" | tail -10
else
    echo "✅ 已触发 _trigger_query"
    echo "$TRIGGER_LOG" | tail -3
fi
echo ""

# 3. 检查 FileSplitter
echo "3. FileSplitter 分块"
echo "----------------------------------------"
SPLIT_LOG=$(docker-compose logs via-server --tail=500 | grep -i "File Splitting\|split\|chunk")
if [ -z "$SPLIT_LOG" ]; then
    echo "❌ 未发现分块日志 - FileSplitter 可能失败"
else
    echo "✅ 发现分块相关日志："
    echo "$SPLIT_LOG" | tail -5
fi
echo ""

# 4. 检查 VLM 入队
echo "4. VLM 任务入队"
echo "----------------------------------------"
ENQUEUE_LOG=$(docker-compose logs via-server --tail=500 | grep -i "enqueue\|Chunk.*VLM")
if [ -z "$ENQUEUE_LOG" ]; then
    echo "❌ 未发现 VLM 入队日志 - chunks 未被创建或入队失败"
else
    echo "✅ 发现 VLM 入队日志："
    echo "$ENQUEUE_LOG" | tail -5
fi
echo ""

# 5. 检查视频信息
echo "5. 视频元信息"
echo "----------------------------------------"
MEDIA_INFO=$(docker-compose logs via-server --tail=500 | grep -i "MediaFileInfo\|video_fps\|video_codec")
if [ -z "$MEDIA_INFO" ]; then
    echo "⚠️  未发现视频元信息日志"
else
    echo "$MEDIA_INFO" | tail -5
fi
echo ""

# 6. 检查异常
echo "6. 异常和错误"
echo "----------------------------------------"
ERROR_LOG=$(docker-compose logs via-server --tail=500 | grep -iE "error|exception|traceback|failed" | grep -v "No items in queue")
if [ -z "$ERROR_LOG" ]; then
    echo "✅ 未发现异常"
else
    echo "⚠️  发现异常："
    echo "$ERROR_LOG" | tail -10
fi
echo ""

# 7. VLM 进程状态
echo "7. VLM 进程队列"
echo "----------------------------------------"
VLM_QUEUE=$(docker-compose logs via-server --tail=30 | grep "Process Index.*No items in queue")
if [ -z "$VLM_QUEUE" ]; then
    echo "VLM 进程正在工作或未启动"
else
    echo "⚠️  VLM 进程空闲（无任务）："
    echo "$VLM_QUEUE" | head -5
fi
echo ""

# 8. 诊断结论
echo "========================================"
echo "诊断结论"
echo "========================================"
echo ""

if [ -z "$TRIGGER_LOG" ]; then
    echo "🔴 问题：_trigger_query 未被调用"
    echo ""
    echo "可能原因："
    echo "1. CA-RAG 初始化失败（虽然你已经解决了 embedding 问题）"
    echo "2. CV Pipeline 处理卡住"
    echo "3. query() 方法中的某个条件检查失败"
    echo ""
    echo "建议："
    echo "- 临时禁用 CV Pipeline: export ENABLE_CV_PIPELINE=false"
    echo "- 检查 CA-RAG reset 是否完成"
elif [ -z "$SPLIT_LOG" ]; then
    echo "🔴 问题：FileSplitter 未执行或失败"
    echo ""
    echo "可能原因："
    echo "1. 视频文件路径错误"
    echo "2. 视频解码失败"
    echo "3. MediaFileInfo.get_info() 失败"
    echo ""
    echo "建议："
    echo "- 检查视频格式和编码"
    echo "- 尝试更简单的视频文件"
elif [ -z "$ENQUEUE_LOG" ]; then
    echo "🔴 问题：Chunks 未入队"
    echo ""
    echo "可能原因："
    echo "1. FileSplitter 创建了 0 个 chunk"
    echo "2. _on_new_chunk 回调未被调用"
    echo "3. VLM Pipeline 未初始化"
    echo ""
    echo "建议："
    echo "- 检查 chunk_duration 设置"
    echo "- 检查视频时长"
else
    echo "🟡 Chunks 已入队，但 VLM 未处理"
    echo ""
    echo "可能原因："
    echo "1. VLM 进程启动失败"
    echo "2. GPU 不可用"
    echo "3. VLM API 调用失败（虽然 Key 是对的）"
    echo ""
    echo "建议："
    echo "- 检查 GPU 状态：docker-compose exec via-server nvidia-smi"
    echo "- 检查 VLM 进程日志中是否有 API 错误"
fi

echo ""
echo "========================================"

