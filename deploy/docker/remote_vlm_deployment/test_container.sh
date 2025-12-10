#!/bin/bash

# 容器名称检测脚本
# 用于验证正确的容器名称

echo "========================================"
echo "VSS 容器状态检查"
echo "========================================"
echo

# 检查所有运行中的容器
echo "📦 当前运行的容器:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|via-server|remote_vlm"

echo
echo "========================================"

# 检查具体的容器名称
CONTAINER_NAME="remote_vlm_deployment-via-server-1"

if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✅ 容器运行正常: $CONTAINER_NAME"
    echo
    echo "容器详细信息:"
    docker inspect $CONTAINER_NAME --format '
    - 容器ID: {{.Id}}
    - 容器名称: {{.Name}}
    - 状态: {{.State.Status}}
    - IP地址: {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}
    '
else
    echo "❌ 容器未运行: $CONTAINER_NAME"
    echo
    echo "可能的原因:"
    echo "1. 服务未启动 - 运行: bash deploy.sh"
    echo "2. 容器名称不同 - 检查上面的容器列表"
    echo
fi

echo "========================================"
echo "测试命令:"
echo "  docker exec $CONTAINER_NAME python3 --version"
echo "========================================"
echo

# 测试执行Python
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "测试执行结果:"
    docker exec $CONTAINER_NAME python3 --version
fi

echo

