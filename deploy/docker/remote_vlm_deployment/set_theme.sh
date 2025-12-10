#!/bin/bash

# VSS UI 主题一键切换脚本
# 用法: bash set_theme.sh [purple|dark|original]

set -e

THEME=${1:-purple}
CONTAINER_NAME="remote_vlm_deployment-via-server-1"

echo "========================================"
echo "VSS UI 主题切换"
echo "========================================"
echo

# 检查容器是否运行
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ 错误: $CONTAINER_NAME 容器未运行"
    echo "请先运行: bash deploy.sh"
    exit 1
fi

# 显示主题信息
case $THEME in
    purple)
        echo "🎨 选择主题: 浅紫色主题"
        echo "   优雅专业，适合正式场景"
        echo "   主色调: #8b5cf6 (紫罗兰)"
        ;;
    dark)
        echo "🎨 选择主题: 科技黑主题"
        echo "   酷炫深色，科技感十足"
        echo "   主色调: #0ea5e9 (青蓝色)"
        ;;
    original)
        echo "🎨 选择主题: NVIDIA 原始主题"
        echo "   恢复默认的绿色配色"
        echo "   主色调: #76b900 (NVIDIA 绿)"
        ;;
    *)
        echo "❌ 未知主题: $THEME"
        echo ""
        echo "可用主题:"
        echo "  purple   - 浅紫色主题（优雅专业）"
        echo "  dark     - 科技黑主题（酷炫深色）"
        echo "  original - NVIDIA 原始主题"
        echo ""
        echo "用法: bash set_theme.sh [purple|dark|original]"
        exit 1
        ;;
esac

echo ""
echo "[1/3] 应用主题配置..."
docker exec $CONTAINER_NAME python3 /opt/nvidia/change_theme.py $THEME

if [ $? -ne 0 ]; then
    echo "❌ 主题应用失败"
    exit 1
fi

echo ""
echo "[2/3] 重启服务..."
docker-compose restart via-server

echo ""
echo "[3/3] 等待服务启动..."
sleep 5

echo ""
echo "========================================"
echo "✅ 主题切换完成！"
echo "========================================"
echo ""
echo "访问地址: http://localhost:9100"
echo ""
echo "💡 提示: 如果页面没有变化，请刷新浏览器（Ctrl+F5 强制刷新）"
echo ""

