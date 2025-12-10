#!/bin/bash
######################################################################################################
# VSS 一键部署脚本 - 使用自己的 LLM + 阿里云 Qwen3-VL-Plus
######################################################################################################

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================"
echo "VSS 一键部署脚本"
echo -e "========================================${NC}"
echo ""

# ============================================================================
# 配置区域 - 修改这里的值
# ============================================================================

# VLM 配置（阿里云 Qwen3-VL-Plus）
export VLM_MODEL_TO_USE="openai-compat"
export VIA_VLM_ENDPOINT="https://dashscope.aliyuncs.com/compatible-mode/v1"
export VIA_VLM_API_KEY="sk-97ef48ca4569402aba42b864f7a92782"  # 改成你的阿里云 API Key
export VIA_VLM_OPENAI_MODEL_DEPLOYMENT_NAME="qwen-vl-plus"
export VLM_SYSTEM_PROMPT="你是一个专业的视频分析助手。请用中文回答用户的问题，提供简洁、准确的回复。"
export ALERT_REVIEW_DEFAULT_VLM_SYSTEM_PROMPT="你是一个专业的视频分析助手。请用中文回答用户的问题，提供简洁、准确的回复。"

# LLM 配置（你自己部署的服务）
export LLM_MODEL_NAME="deepseek-ai/DeepSeek-V3.2-Exp"          # 改成你的模型名
export LLM_BASE_URL="https://maas.spader-ai.com/v1"   # 改成你的 LLM 地址
export LLM_API_KEY="sk-uFlPvqI6yiSEeOSx_JNHWQ"                                  # 如果需要 API Key，填这里

# Embedding 配置 - 方案1: NVIDIA 免费 API（推荐）
export EMBEDDING_MODEL_NAME="nvidia/llama-3.2-nv-embedqa-1b-v2"
export EMBEDDING_BASE_URL="https://integrate.api.nvidia.com/v1"
export EMBEDDING_API_KEY="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"

# 方案2: 智谱AI（需要特殊补丁，目前暂不可用）
# export EMBEDDING_MODEL_NAME="embedding-3"
# export EMBEDDING_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
# export EMBEDDING_API_KEY="8226029792e533fc5e2d4d408ccf172e.lep8MOHiQFZ1gX7Y"
# Reranker 配置（可选组件，已禁用）
# export RERANKER_MODEL_NAME="bge-reranker-v2-m3"
# export RERANKER_BASE_URL="http://192.168.0.157:8080/v1"
# export RERANKER_API_KEY=""

# 数据库配置
export GRAPH_DB_HOST="graph-db"
export GRAPH_DB_BOLT_PORT="7687"
export GRAPH_DB_HTTP_PORT="7474"
export GRAPH_DB_USERNAME="neo4j"
export GRAPH_DB_PASSWORD="VssPassword2024!"  # 建议修改为强密码

export MILVUS_DB_HOST="milvus-standalone"
export MILVUS_DB_GRPC_PORT="19530"
export MILVUS_DB_HTTP_PORT="9091"

export ARANGO_DB_HOST="arango-db"
export ARANGO_DB_PORT="8529"
export ARANGO_DB_USERNAME="root"
export ARANGO_DB_PASSWORD="VssPassword2024!"  # 建议修改为强密码

export MINIO_HOST="minio"
export MINIO_PORT="9000"
export MINIO_WEBUI_PORT="9001"
export MINIO_ROOT_USER="minio"
export MINIO_ROOT_PASSWORD="minio123456"
export MINIO_USERNAME="minio"
export MINIO_PASSWORD="minio123456"

# 端口配置
export BACKEND_PORT="8080"
export FRONTEND_PORT="9100"

# 功能开关
export DISABLE_FRONTEND="false"
export DISABLE_CA_RAG="true"  # 启用 CA-RAG（Milvus 地址已硬编码）
export DISABLE_GUARDRAILS="true"  # 禁用 Guardrails（需要 NVIDIA API）
export DISABLE_CV_PIPELINE="true"
export ENABLE_AUDIO="false"
export ENABLE_DENSE_CAPTION="true"

# GPU 配置
export NVIDIA_VISIBLE_DEVICES="all"  # 或指定 GPU ID，如 "0,1"
export NUM_GPUS="1"
export VSS_NUM_GPUS_PER_VLM_PROC="1"

# VLM 处理配置（简化配置用于调试）
export VLM_BATCH_SIZE="1"  # 减小 batch size
export NUM_VLM_PROCS="1"
export VLM_DEFAULT_NUM_FRAMES_PER_CHUNK="8"  # 减少帧数

# 日志级别
export VSS_LOG_LEVEL="DEBUG"  # 启用 DEBUG 日志以查看详细信息

# 配置文件路径
export CA_RAG_CONFIG="${PWD}/config.yaml"

# 容器镜像配置（如果要替换镜像，修改这里）
export VIA_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/blueprint/vss-engine:2.4.0"
export NEO4J_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/library/neo4j:5.26.4"
export ARANGO_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/arangodb/arangodb:3.12.4"
export MINIO_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/minio/minio:latest"
export MILVUS_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/milvusdb/milvus:v2.5.4"
export ELASTICSEARCH_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/library/elasticsearch:9.1.2"

# 监控组件镜像（可选，仅在 perf-profiling 模式下使用）
export OTEL_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/otel/opentelemetry-collector-contrib:latest"
export PROMETHEUS_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/prom/prometheus:latest"
export JAEGER_IMAGE="swr.cn-southwest-2.myhuaweicloud.com/knowv/jaegertracing/all-in-one:latest"

# # 容器镜像配置（如果要替换镜像，修改这里）
# export VIA_IMAGE="nvcr.io/nvidia/blueprint/vss-engine:2.4.0"
# export NEO4J_IMAGE="neo4j:5.26.4"
# export ARANGO_IMAGE="arangodb/arangodb:3.12.4"
# export MINIO_IMAGE="minio/minio:latest"
# export MILVUS_IMAGE="milvusdb/milvus:v2.5.4"
# export ELASTICSEARCH_IMAGE="elasticsearch:9.1.2"

# # 监控组件镜像（可选，仅在 perf-profiling 模式下使用）
# export OTEL_IMAGE="otel/opentelemetry-collector-contrib:latest"
# export PROMETHEUS_IMAGE="prom/prometheus:latest"
# export JAEGER_IMAGE="jaegertracing/all-in-one:latest"


# 镜像同步命令（供参考）
# oras cp nvcr.io/nvidia/blueprint/vss-engine:2.4.0 swr.cn-southwest-2.myhuaweicloud.com/knowv/blueprint/vss-engine:2.4.0 --platform=linux/amd64
# oras cp docker.io/library/neo4j:5.26.4 swr.cn-southwest-2.myhuaweicloud.com/knowv/library/neo4j:5.26.4 --platform=linux/amd64
# oras cp docker.io/arangodb/arangodb:3.12.4 swr.cn-southwest-2.myhuaweicloud.com/knowv/arangodb/arangodb:3.12.4 --platform=linux/amd64
# oras cp docker.io/minio/minio:latest swr.cn-southwest-2.myhuaweicloud.com/knowv/minio/minio:latest --platform=linux/amd64
# oras cp docker.io/milvusdb/milvus:v2.5.4 swr.cn-southwest-2.myhuaweicloud.com/knowv/milvusdb/milvus:v2.5.4 --platform=linux/amd64
# oras cp docker.io/library/elasticsearch:9.1.2 swr.cn-southwest-2.myhuaweicloud.com/knowv/library/elasticsearch:9.1.2 --platform=linux/amd64
# oras cp docker.io/otel/opentelemetry-collector-contrib:latest swr.cn-southwest-2.myhuaweicloud.com/knowv/otel/opentelemetry-collector-contrib:latest --platform=linux/amd64
# oras cp docker.io/prom/prometheus:latest swr.cn-southwest-2.myhuaweicloud.com/knowv/prom/prometheus:latest --platform=linux/amd64
# oras cp docker.io/jaegertracing/all-in-one:latest swr.cn-southwest-2.myhuaweicloud.com/knowv/jaegertracing/all-in-one:latest --platform=linux/amd64
# ============================================================================
# 检查函数
# ============================================================================

check_docker() {
    echo -e "${YELLOW}[1/4] 检查 Docker 环境...${NC}"
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker 未安装${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}✗ Docker 未运行，请先启动 Docker Desktop${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker 已就绪${NC}"
}

check_config() {
    echo -e "${YELLOW}[2/4] 检查配置...${NC}"
    
    if [[ "$VIA_VLM_API_KEY" == "sk-xxxxxxxxxxxxxx" ]]; then
        echo -e "${RED}✗ 请先修改脚本中的 VIA_VLM_API_KEY${NC}"
        exit 1
    fi
    
    if [[ "$LLM_BASE_URL" == "http://192.168.1.100:8000/v1" ]]; then
        echo -e "${YELLOW}⚠ 警告: LLM_BASE_URL 似乎未修改，请确认是否正确${NC}"
        read -p "是否继续？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✓ 配置检查通过${NC}"
}

create_env_file() {
    echo -e "${YELLOW}[3/4] 创建 .env 文件...${NC}"
    
    cat > .env << EOF
# 自动生成的环境配置文件
# 生成时间: $(date)

# VLM 配置
VLM_MODEL_TO_USE=${VLM_MODEL_TO_USE}
VIA_VLM_ENDPOINT=${VIA_VLM_ENDPOINT}
VIA_VLM_API_KEY=${VIA_VLM_API_KEY}
VIA_VLM_OPENAI_MODEL_DEPLOYMENT_NAME=${VIA_VLM_OPENAI_MODEL_DEPLOYMENT_NAME}
VLM_SYSTEM_PROMPT=${VLM_SYSTEM_PROMPT}
ALERT_REVIEW_DEFAULT_VLM_SYSTEM_PROMPT=${ALERT_REVIEW_DEFAULT_VLM_SYSTEM_PROMPT}
VLM_BATCH_SIZE=${VLM_BATCH_SIZE}
NUM_VLM_PROCS=${NUM_VLM_PROCS}
VLM_DEFAULT_NUM_FRAMES_PER_CHUNK=${VLM_DEFAULT_NUM_FRAMES_PER_CHUNK}

# LLM 配置
LLM_MODEL_NAME=${LLM_MODEL_NAME}
LLM_BASE_URL=${LLM_BASE_URL}
LLM_API_KEY=${LLM_API_KEY}

# Embedding 配置
EMBEDDING_MODEL_NAME=${EMBEDDING_MODEL_NAME}
EMBEDDING_BASE_URL=${EMBEDDING_BASE_URL}
EMBEDDING_API_KEY=${EMBEDDING_API_KEY}

# Reranker 配置（已禁用）
# RERANKER_MODEL_NAME=${RERANKER_MODEL_NAME}
# RERANKER_BASE_URL=${RERANKER_BASE_URL}
# RERANKER_API_KEY=${RERANKER_API_KEY}

# 数据库配置
GRAPH_DB_HOST=${GRAPH_DB_HOST}
GRAPH_DB_BOLT_PORT=${GRAPH_DB_BOLT_PORT}
GRAPH_DB_HTTP_PORT=${GRAPH_DB_HTTP_PORT}
GRAPH_DB_USERNAME=${GRAPH_DB_USERNAME}
GRAPH_DB_PASSWORD=${GRAPH_DB_PASSWORD}

MILVUS_DB_HOST=${MILVUS_DB_HOST}
MILVUS_DB_GRPC_PORT=${MILVUS_DB_GRPC_PORT}
MILVUS_DB_HTTP_PORT=${MILVUS_DB_HTTP_PORT}

ARANGO_DB_HOST=${ARANGO_DB_HOST}
ARANGO_DB_PORT=${ARANGO_DB_PORT}
ARANGO_DB_USERNAME=${ARANGO_DB_USERNAME}
ARANGO_DB_PASSWORD=${ARANGO_DB_PASSWORD}

MINIO_HOST=${MINIO_HOST}
MINIO_PORT=${MINIO_PORT}
MINIO_WEBUI_PORT=${MINIO_WEBUI_PORT}
MINIO_ROOT_USER=${MINIO_ROOT_USER}
MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
MINIO_USERNAME=${MINIO_USERNAME}
MINIO_PASSWORD=${MINIO_PASSWORD}

# 端口配置
BACKEND_PORT=${BACKEND_PORT}
FRONTEND_PORT=${FRONTEND_PORT}

# 功能开关
DISABLE_FRONTEND=${DISABLE_FRONTEND}
DISABLE_CA_RAG=${DISABLE_CA_RAG}
DISABLE_GUARDRAILS=${DISABLE_GUARDRAILS}
DISABLE_CV_PIPELINE=${DISABLE_CV_PIPELINE}
ENABLE_AUDIO=${ENABLE_AUDIO}
ENABLE_DENSE_CAPTION=${ENABLE_DENSE_CAPTION}

# GPU 配置
NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES}
NUM_GPUS=${NUM_GPUS}
VSS_NUM_GPUS_PER_VLM_PROC=${VSS_NUM_GPUS_PER_VLM_PROC}

# 其他配置
VSS_LOG_LEVEL=${VSS_LOG_LEVEL}
CA_RAG_CONFIG=${CA_RAG_CONFIG}

# 容器镜像
VIA_IMAGE=${VIA_IMAGE}
NEO4J_IMAGE=${NEO4J_IMAGE}
ARANGO_IMAGE=${ARANGO_IMAGE}
MINIO_IMAGE=${MINIO_IMAGE}
MILVUS_IMAGE=${MILVUS_IMAGE}
ELASTICSEARCH_IMAGE=${ELASTICSEARCH_IMAGE}
OTEL_IMAGE=${OTEL_IMAGE}
PROMETHEUS_IMAGE=${PROMETHEUS_IMAGE}
JAEGER_IMAGE=${JAEGER_IMAGE}
EOF
    
    echo -e "${GREEN}✓ .env 文件已创建${NC}"
}

deploy_services() {
    echo -e "${YELLOW}[4/4] 启动服务...${NC}"
    echo ""
    
    # 拉取镜像
    echo -e "${BLUE}拉取 Docker 镜像（首次运行需要几分钟）...${NC}"
    docker compose pull
    
    echo ""
    echo -e "${BLUE}启动所有服务...${NC}"
    docker compose up -d
    
    echo ""
    echo -e "${GREEN}✓ 服务启动完成${NC}"
}

show_status() {
    echo ""
    echo -e "${BLUE}========================================"
    echo "服务状态"
    echo -e "========================================${NC}"
    docker compose ps
    
    echo ""
    echo -e "${BLUE}========================================"
    echo "访问地址"
    echo -e "========================================${NC}"
    echo -e "${GREEN}Web UI:${NC}       http://localhost:${FRONTEND_PORT}"
    echo -e "${GREEN}Backend API:${NC}  http://localhost:${BACKEND_PORT}"
    echo -e "${GREEN}健康检查:${NC}     http://localhost:${BACKEND_PORT}/health"
    
    echo ""
    echo -e "${BLUE}========================================"
    echo "常用命令"
    echo -e "========================================${NC}"
    echo -e "${YELLOW}查看日志:${NC}     docker compose logs -f via-server"
    echo -e "${YELLOW}停止服务:${NC}     docker compose down"
    echo -e "${YELLOW}重启服务:${NC}     docker compose restart via-server"
    echo -e "${YELLOW}查看状态:${NC}     docker compose ps"
    
    echo ""
    echo -e "${GREEN}部署完成！请等待 30 秒后访问 Web UI${NC}"
}

# ============================================================================
# 主流程
# ============================================================================

main() {
    check_docker
    check_config
    create_env_file
    deploy_services
    show_status
}

# 执行主流程
main

