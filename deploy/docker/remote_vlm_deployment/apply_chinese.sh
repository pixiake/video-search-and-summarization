#!/bin/bash

# VSS 一键中文化脚本
# 作用：应用UI中文化补丁并重启服务

set -e

CONTAINER_NAME="remote_vlm_deployment-via-server-1"

echo "========================================"
echo "VSS 一键中文化"
echo "========================================"
echo

# 检查容器是否运行
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "错误: $CONTAINER_NAME 容器未运行"
    echo "请先运行: bash deploy.sh"
    exit 1
fi

echo "[1/3] 执行UI中文化补丁..."
docker exec $CONTAINER_NAME python3 /opt/nvidia/ui_chinese_patch.py

echo
echo "[2/3] 重启服务..."
docker-compose restart via-server

echo
echo "[3/3] 等待服务启动..."
sleep 5

echo
echo "========================================"
echo "✓ 中文化完成！"
echo "========================================"
echo
echo "访问地址:"
echo "  http://localhost:9100"
echo
echo "如需恢复英文界面:"
echo "  docker-compose down && bash deploy.sh"
echo

