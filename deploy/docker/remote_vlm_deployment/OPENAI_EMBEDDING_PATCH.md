# OpenAI-Compatible Embedding 补丁使用说明

## 🎯 问题背景

VSS 默认使用 `langchain_nvidia_ai_endpoints` 库，该库硬编码了 NVIDIA API 的调用方式：
- ❌ 只接受 `nvapi-xxx` 格式的 token
- ❌ 只能调用 NVIDIA 的 embedding API
- ❌ 无法使用其他厂商的 API（如智谱AI、阿里云、OpenAI等）

## ✅ 解决方案

通过 **Monkey Patch** 的方式，在容器启动时自动替换 NVIDIA embedding 模块，使其支持任何 OpenAI-compatible 的 embedding API。

## 📁 文件说明

### 1. `openai_embedding_patch.py`
- **作用**: Python 补丁文件
- **原理**: 劫持 `langchain_nvidia_ai_endpoints` 的导入，替换为 `langchain_openai.OpenAIEmbeddings`
- **触发**: 检测到 `EMBEDDING_BASE_URL` 不包含 `nvidia.com` 时自动应用

### 2. `start_vss_with_patch.sh`
- **作用**: VSS 启动包装脚本
- **功能**: 
  - 创建 `sitecustomize.py` 让 Python 自动加载补丁
  - 调用原始的 `start_via.sh`

### 3. `compose.yaml` (已修改)
- 挂载补丁文件到容器
- 使用新的启动脚本

## 🚀 使用方法

### 配置 Embedding 服务

在 `deploy.sh` 中配置你的 embedding API：

```bash
# 示例1: 智谱AI
export EMBEDDING_MODEL_NAME="embedding-3"
export EMBEDDING_BASE_URL="https://open.bigmodel.cn/api/paas/v4"
export EMBEDDING_API_KEY="你的智谱AI_KEY"

# 示例2: 阿里云 DashScope
export EMBEDDING_MODEL_NAME="text-embedding-v3"
export EMBEDDING_BASE_URL="https://dashscope.aliyuncs.com/compatible-mode/v1"
export EMBEDDING_API_KEY="sk-xxxxx"

# 示例3: OpenAI
export EMBEDDING_MODEL_NAME="text-embedding-3-small"
export EMBEDDING_BASE_URL="https://api.openai.com/v1"
export EMBEDDING_API_KEY="sk-xxxxx"

# 示例4: 本地 vLLM 服务
export EMBEDDING_MODEL_NAME="BAAI/bge-large-zh-v1.5"
export EMBEDDING_BASE_URL="http://192.168.1.100:8001/v1"
export EMBEDDING_API_KEY="not-needed"
```

### 启动服务

```bash
# 运行部署脚本
./deploy.sh

# 或手动启动
docker-compose up -d

# 查看日志确认补丁已加载
docker-compose logs via-server | grep -i "embedding\|补丁\|patch"
```

## ✅ 验证补丁是否生效

### 方法1：查看启动日志

```bash
docker-compose logs via-server | head -100
```

**期望看到**：
```
================================================
VSS 启动（OpenAI-Compatible Embedding 支持）
================================================
✅ 发现 embedding 补丁文件
✅ 补丁已配置为自动加载
...
====================================================================
🔧 检测到非 NVIDIA embedding 配置
   Base URL: https://open.bigmodel.cn/api/paas/v4
   应用 OpenAI-compatible embedding 补丁...
====================================================================
✅ 初始化 OpenAI-compatible Embedding:
   Model: embedding-3
   Base URL: https://open.bigmodel.cn/api/paas/v4
✅ OpenAI-compatible embedding 补丁已成功应用
====================================================================
```

### 方法2：测试 embedding 功能

进入容器测试：

```bash
docker-compose exec via-server python3 << 'EOF'
import os
os.environ['EMBEDDING_BASE_URL'] = 'https://open.bigmodel.cn/api/paas/v4'
os.environ['EMBEDDING_MODEL_NAME'] = 'embedding-3'
os.environ['EMBEDDING_API_KEY'] = 'your-key'

# 导入补丁
import sys
sys.path.insert(0, '/opt/nvidia')
import openai_embedding_patch

# 测试导入
from langchain_nvidia_ai_endpoints.embeddings import NVIDIAEmbeddings
emb = NVIDIAEmbeddings()
print(f"✅ Embedding 类型: {type(emb)}")
print(f"✅ 基类: {type(emb).__bases__}")

# 测试调用
try:
    result = emb.embed_query("测试文本")
    print(f"✅ Embedding 维度: {len(result)}")
except Exception as e:
    print(f"❌ 调用失败: {e}")
EOF
```

## 🔧 故障排查

### 问题1：补丁未加载

**症状**：仍然看到 `token contains an invalid number of segments` 错误

**解决**：
```bash
# 检查文件是否挂载成功
docker-compose exec via-server ls -l /opt/nvidia/openai_embedding_patch.py

# 检查启动脚本权限
docker-compose exec via-server ls -l /opt/nvidia/start_vss_with_patch.sh

# 重新启动
docker-compose restart via-server
```

### 问题2：Embedding API 调用失败

**症状**：补丁加载成功，但仍有 embedding 错误

**可能原因**：
1. API Key 无效
2. base_url 格式不对（需要以 `/v1` 结尾）
3. 模型名称错误

**解决**：
```bash
# 测试 API 连接
curl -X POST "https://open.bigmodel.cn/api/paas/v4/embeddings" \
  -H "Authorization: Bearer 你的KEY" \
  -H "Content-Type: application/json" \
  -d '{"input": "test", "model": "embedding-3"}'
```

### 问题3：CA-RAG 初始化失败

**症状**：其他错误导致 CA-RAG 无法初始化

**临时方案**：
```bash
# 禁用 CA-RAG 先测试 VLM 摘要
export DISABLE_CA_RAG="true"
./deploy.sh
```

## 📊 支持的 Embedding 服务

只要实现了 OpenAI-compatible API 的服务都支持：

| 服务商 | 是否支持 | 配置示例 |
|--------|---------|---------|
| ✅ 智谱AI | 支持 | `base_url: https://open.bigmodel.cn/api/paas/v4` |
| ✅ 阿里云 DashScope | 支持 | `base_url: https://dashscope.aliyuncs.com/compatible-mode/v1` |
| ✅ OpenAI | 支持 | `base_url: https://api.openai.com/v1` |
| ✅ vLLM | 支持 | `base_url: http://localhost:8000/v1` |
| ✅ Text-Embeddings-Inference | 支持 | `base_url: http://localhost:8080/v1` |
| ✅ Xinference | 支持 | `base_url: http://localhost:9997/v1` |
| ❌ NVIDIA NIM | 原生支持 | 不需要补丁 |

## 💡 技术原理

### Monkey Patch 工作流程

```
1. VSS 启动
   ↓
2. start_vss_with_patch.sh 创建 sitecustomize.py
   ↓
3. Python 解释器启动时自动加载 sitecustomize.py
   ↓
4. sitecustomize.py 导入 openai_embedding_patch
   ↓
5. 补丁检测 EMBEDDING_BASE_URL 是否为非 NVIDIA
   ↓
6. 创建假的 langchain_nvidia_ai_endpoints 模块
   ↓
7. 将 NVIDIAEmbeddings 替换为 OpenAIEmbeddings
   ↓
8. 注入到 sys.modules
   ↓
9. VSS 代码正常导入，但实际使用的是 OpenAI API
```

### 关键代码片段

```python
# 创建假模块
fake_nvidia_module = ModuleType('langchain_nvidia_ai_endpoints')

# 用 OpenAI embeddings 创建兼容类
class NVIDIAEmbeddingsCompatible(OpenAIEmbeddings):
    def __init__(self, model=None, base_url=None, api_key=None, **kwargs):
        super().__init__(
            model=model,
            openai_api_base=base_url,
            openai_api_key=api_key,
            **kwargs
        )

# 注入到系统
sys.modules['langchain_nvidia_ai_endpoints'] = fake_nvidia_module
```

## 🎉 总结

这个补丁方案：
- ✅ 无需修改 VSS 源代码
- ✅ 无需重新构建镜像
- ✅ 通过简单的文件挂载即可生效
- ✅ 支持所有 OpenAI-compatible API
- ✅ 可以随时回退到原始配置

现在你可以自由选择任何 embedding 服务，不再受 NVIDIA API 限制！ 🚀

