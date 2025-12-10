#!/bin/bash

# KnowV 品牌一键应用脚本
# 功能：
#   1. 替换机器人头像（NVIDIA → KnowV 机器人）
#   2. 更新产品名称（视频智能分析系统 → KnowV 视频智能分析系统）
#   3. 应用紫色主题
#   4. 应用中文化

set -e

CONTAINER_NAME="remote_vlm_deployment-via-server-1"

echo "========================================"
echo "🎨 KnowV 品牌一键应用"
echo "========================================"
echo

# 检查容器是否运行
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ 错误: $CONTAINER_NAME 容器未运行"
    echo "请先运行: bash deploy.sh"
    exit 1
fi

echo "📦 应用 KnowV 品牌定制..."
echo

# 步骤1: 替换机器人头像
echo "[1/4] 替换聊天机器人头像..."
docker exec $CONTAINER_NAME bash -c 'pip install pillow -q 2>/dev/null || true'
docker exec $CONTAINER_NAME python3 /opt/nvidia/replace_avatar.py

# 步骤2: 应用中文化（包含 KnowV 品牌名称）
echo
echo "[2/4] 应用中文化（KnowV 品牌）..."
docker exec $CONTAINER_NAME python3 /opt/nvidia/ui_chinese_patch.py

# 步骤3: 应用紫色主题
echo
echo "[3/4] 应用 KnowV 紫色主题..."
docker exec $CONTAINER_NAME python3 /opt/nvidia/change_theme.py purple

# 步骤4: 重启服务
echo
echo "[4/4] 重启服务使修改生效..."
docker-compose restart via-server

echo
echo "等待服务启动..."
sleep 10

echo
echo "========================================"
echo "✅ KnowV 品牌应用完成！"
echo "========================================"
echo
echo "🎉 已完成的定制:"
echo "  ✓ 产品名称: KnowV 视频智能分析系统"
echo "  ✓ 机器人头像: KnowV 风格紫色机器人"
echo "  ✓ UI主题: 优雅紫色主题"
echo "  ✓ 界面语言: 完整中文"
echo "  ✓ Logo: 简洁视频图标（无NVIDIA品牌）"
echo
echo "访问地址: http://localhost:9100"
echo
echo "💡 提示: 刷新浏览器查看效果（Ctrl+F5 强制刷新）"
echo

