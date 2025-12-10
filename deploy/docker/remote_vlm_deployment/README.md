# VSS 快速部署 - 使用自己的 LLM + 阿里云 Qwen3-VL

## 第 1 步：修改 .env 文件

```bash
nano .env
```

填写以下内容（**只需修改这5行**）：

```bash
# 第 3 行 - 你的阿里云 API Key
VIA_VLM_API_KEY=sk-xxxxx

# 第 8 行 - 你的 LLM 模型名称（OpenAI 格式）
LLM_MODEL_NAME=qwen2.5-72b-instruct

# 第 9 行 - 你的 LLM 服务地址
LLM_BASE_URL=http://192.168.1.100:8000/v1

# 第 14 行 - 你的 Embedding 模型名称
EMBEDDING_MODEL_NAME=bge-m3

# 第 15 行 - 你的 Embedding 服务地址
EMBEDDING_BASE_URL=http://192.168.1.100:8001/v1
```

💡 **注意**: 
- 如果 LLM/Embedding 不需要 API Key，保持 `LLM_API_KEY` 为空即可
- 如果没有 Reranker，可以不填或使用相同的 Embedding 服务

---

## 第 2 步：启动服务

```bash
# 确保 Docker 正在运行
docker compose up -d

# 查看日志
docker compose logs -f via-server
```

---

## 第 3 步：访问 UI

浏览器打开：**http://localhost:9100**

---

## 停止服务

```bash
docker compose down
```

---

## 故障排查

### 查看日志
```bash
docker compose logs -f via-server
```

### 测试 API
```bash
# 测试健康状态
curl http://localhost:8080/health

# 测试 LLM 连接
curl http://你的LLM服务地址/v1/models
```

### 重启服务
```bash
docker compose restart via-server
```

---

就这么简单！🎉

