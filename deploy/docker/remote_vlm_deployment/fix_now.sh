#!/bin/bash

# 紧急修复脚本 - 恢复被错误替换的代码

set -e

CONTAINER_NAME="remote_vlm_deployment-via-server-1"

echo "========================================"
echo "🔧 紧急修复：恢复错误的中文替换"
echo "========================================"
echo

# 检查容器是否运行
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "❌ 容器未运行，直接重启即可"
    echo ""
    echo "执行以下命令："
    echo "  docker-compose down"
    echo "  docker-compose up -d"
    exit 0
fi

echo "[1/2] 恢复容器内被错误替换的代码..."
echo "      修复 media_type 字段..."

# 在容器内执行修复
docker exec $CONTAINER_NAME bash -c '
# 查找所有可能被错误替换的 Python 文件
find /opt/nvidia/via -name "*.py" -type f | while read file; do
    # 恢复 media_type = "视频" -> media_type = "video"
    if grep -q "media_type.*视频" "$file" 2>/dev/null; then
        sed -i "s/media_type = \"视频\"/media_type = \"video\"/g" "$file"
        sed -i "s/media_type == \"视频\"/media_type == \"video\"/g" "$file"
        sed -i "s/\"media_type\": \"视频\"/\"media_type\": \"video\"/g" "$file"
        echo "  ✓ 修复: $file"
    fi
    
    # 恢复 media_type = "图片" -> media_type = "image"
    if grep -q "media_type.*图片" "$file" 2>/dev/null; then
        sed -i "s/media_type = \"图片\"/media_type = \"image\"/g" "$file"
        sed -i "s/media_type == \"图片\"/media_type == \"image\"/g" "$file"
        sed -i "s/\"media_type\": \"图片\"/\"media_type\": \"image\"/g" "$file"
        echo "  ✓ 修复: $file"
    fi
done
'

if [ $? -eq 0 ]; then
    echo ""
    echo "[2/2] 重启服务..."
    docker-compose restart via-server
    
    echo ""
    echo "========================================"
    echo "✅ 修复完成！"
    echo "========================================"
    echo ""
    echo "请刷新浏览器页面测试"
    echo "访问: http://localhost:9100"
else
    echo ""
    echo "========================================"
    echo "❌ 修复失败"
    echo "========================================"
    echo ""
    echo "建议完全重启："
    echo "  docker-compose down"
    echo "  docker-compose up -d"
    echo "  bash apply_chinese.sh  # 使用修正后的脚本"
fi

echo ""

