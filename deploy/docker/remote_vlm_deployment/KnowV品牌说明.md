# KnowV 品牌定制说明

## 🎨 品牌特色

**KnowV 视频智能分析系统** 是基于 NVIDIA VSS 的完全定制版本，具有以下特色：

### ✨ 核心定制
1. **品牌名称**: KnowV 视频智能分析系统
2. **机器人头像**: 优雅的紫色KnowV机器人（替代NVIDIA logo）
3. **UI主题**: 紫色科技风（主色调 #8b5cf6）
4. **界面语言**: 完整中文化（100+ 处文本）
5. **Logo**: 简洁的视频图标（无NVIDIA品牌元素）

---

## 🚀 一键应用 KnowV 品牌

### 方式A：完整品牌定制（推荐）

```bash
cd /Users/cauchy/gitrepo/video-search-and-summarization/deploy/docker/remote_vlm_deployment

# 一键应用所有 KnowV 品牌元素
bash apply_knowv_brand.sh
```

**此脚本会自动完成：**
- ✅ 替换聊天机器人头像（NVIDIA → KnowV 机器人）
- ✅ 更新产品名称（→ KnowV 视频智能分析系统）
- ✅ 应用紫色主题
- ✅ 应用完整中文化
- ✅ 自动重启服务

### 方式B：分步定制

如果需要单独控制每个部分：

```bash
# 1. 只替换机器人头像
docker exec remote_vlm_deployment-via-server-1 python3 /opt/nvidia/replace_avatar.py
docker-compose restart via-server

# 2. 只应用中文化（包含 KnowV 名称）
bash apply_chinese.sh

# 3. 只切换主题
bash set_theme.sh purple
```

---

## 📊 定制详情

### 1. 机器人头像设计

**原始 NVIDIA 头像 → KnowV 机器人头像**

**设计元素：**
- 🎨 **配色**: 紫色渐变背景 (#8b5cf6 → #7b52e6)
- 🤖 **造型**: 简约可爱的机器人
  - 圆角矩形头部（白色）
  - 两只圆形眼睛（紫色）
  - 弧形微笑（紫色）
  - 天线装饰（白色）
  - 简化身体（白色圆角矩形）
- 📐 **尺寸**: 60x60 像素
- 🎯 **风格**: 现代、友好、专业

**技术实现：**
- 使用 Python PIL 库动态生成
- 替换容器内 `client/assets/chatbot-icon-60px.png`
- 支持透明背景和圆形边缘

### 2. 产品名称

**主标题更新：**
```
原: Video Search and Summarization Agent
新: KnowV 视频智能分析系统
```

**品牌定位：**
- **Know**: 知识、认知
- **V**: Video（视频）
- 寓意：通过视频获取知识和洞察

### 3. UI 主题

**KnowV 紫色主题特征：**
- 主色调: `#8b5cf6` (紫罗兰色)
- 强调色: `#a78bfa` (浅紫色)
- 悬停色: `#7c3aed` (深紫色)
- 背景色: `#faf5ff` (极浅紫色)
- 文字色: `#4c1d95` (深紫色)

**设计理念：**
- 优雅而不失专业
- 科技感与亲和力并存
- 符合企业级应用审美

### 4. 中文化

**覆盖范围：**
- ✅ 页面标题和 Tab 标签
- ✅ 所有按钮文字（20+ 个）
- ✅ 所有输入框标签（15+ 个）
- ✅ 所有参数标签（25+ 个）
- ✅ 所有提示信息（10+ 个）

**翻译原则：**
- 专业准确
- 简洁易懂
- 符合中文表达习惯

---

## 🔄 完整部署流程

### 首次部署（包含 KnowV 品牌）

```bash
# 1. 进入部署目录
cd /Users/cauchy/gitrepo/video-search-and-summarization/deploy/docker/remote_vlm_deployment

# 2. 启动服务
bash deploy.sh

# 3. 等待服务启动（约30秒）
sleep 30

# 4. 应用 KnowV 品牌（一键完成所有定制）
bash apply_knowv_brand.sh

# 5. 访问系统
# http://localhost:9100
```

### 更新部署（保留数据）

```bash
# 如果需要重新应用品牌定制
cd /Users/cauchy/gitrepo/video-search-and-summarization/deploy/docker/remote_vlm_deployment

# 重新应用 KnowV 品牌
bash apply_knowv_brand.sh
```

### 完全重置

```bash
# 停止并删除所有容器
docker-compose down

# 重新部署
bash deploy.sh
sleep 30
bash apply_knowv_brand.sh
```

---

## 🎯 效果验证

访问 `http://localhost:9100` 后，检查以下内容：

### ✅ 品牌元素检查清单

| 项目 | 位置 | 预期效果 |
|------|------|----------|
| **产品名称** | 页面顶部标题 | 显示 "KnowV 视频智能分析系统" |
| **Logo图标** | 左上角 | 紫色简洁视频图标（无NVIDIA元素）|
| **机器人头像** | 聊天窗口 | 紫色可爱机器人（非NVIDIA logo）|
| **主题配色** | 全局UI | 紫色科技风格 |
| **界面文字** | 所有UI元素 | 完整中文显示 |
| **Tab标签** | 顶部导航 | "视频文件摘要与问答"等中文 |
| **按钮文字** | 所有按钮 | "生成摘要"、"提问"等中文 |
| **参数标签** | 参数面板 | "温度"、"最大令牌数"等中文 |

### 📸 对比截图参考

**修改前（NVIDIA 原版）：**
- ❌ 标题: "Video Search and Summarization Agent"
- ❌ Logo: NVIDIA "eye" 图标
- ❌ 机器人头像: NVIDIA logo
- ❌ 主题: 绿色（#76b900）
- ❌ 语言: 英文

**修改后（KnowV 品牌）：**
- ✅ 标题: "KnowV 视频智能分析系统"
- ✅ Logo: 紫色视频图标
- ✅ 机器人头像: 紫色可爱机器人
- ✅ 主题: 紫色（#8b5cf6）
- ✅ 语言: 中文

---

## 🛠️ 技术文件说明

### 核心定制文件

| 文件 | 功能 | 位置 |
|------|------|------|
| `apply_knowv_brand.sh` | 一键品牌应用脚本 | 部署目录 |
| `replace_avatar.py` | 机器人头像替换脚本 | 挂载到容器 `/opt/nvidia/` |
| `ui_chinese_patch.py` | UI 中文化脚本（含 KnowV 名称）| 挂载到容器 |
| `change_theme.py` | 主题切换脚本 | 挂载到容器 |
| `compose.yaml` | Docker 编排文件（含挂载配置）| 部署目录 |

### 文件挂载配置

在 `compose.yaml` 中的挂载：
```yaml
volumes:
  - ./ui_chinese_patch.py:/opt/nvidia/ui_chinese_patch.py:ro
  - ./change_theme.py:/opt/nvidia/change_theme.py:ro
  - ./replace_avatar.py:/opt/nvidia/replace_avatar.py:ro
```

---

## ⚠️ 注意事项

### 持久性说明

1. **临时修改（容器重建后失效）：**
   - 机器人头像替换
   - UI 中文化
   - 主题颜色

2. **永久修改（重建后保留）：**
   - `config.yaml` 中的 Prompt 配置
   - `compose.yaml` 中的环境变量

### 重要提示

⚠️ **容器重建后需重新应用品牌**

当执行 `docker-compose down` 后，所有临时修改会丢失。需要重新执行：
```bash
docker-compose up -d
sleep 30
bash apply_knowv_brand.sh
```

💡 **建议做法：**
- 将 `apply_knowv_brand.sh` 添加到部署流程
- 或者在 `deploy.sh` 末尾自动调用

---

## 🎨 高级定制

### 自定义机器人头像

如果需要使用自己的头像图片：

```bash
# 1. 准备一个 60x60 的 PNG 图片
# 文件名: my-custom-avatar.png

# 2. 进入容器
docker exec -it remote_vlm_deployment-via-server-1 bash

# 3. 替换头像文件
cp my-custom-avatar.png /opt/nvidia/via/via-engine/client/assets/chatbot-icon-60px.png

# 4. 退出容器并重启
exit
docker-compose restart via-server
```

### 自定义主题颜色

编辑 `change_theme.py` 中的颜色定义：
```python
THEMES = {
    "knowv_purple": {
        "primary_color": "#8b5cf6",      # 修改主色调
        "secondary_color": "#a78bfa",    # 修改次要色
        # ... 其他颜色
    }
}
```

### 自定义产品名称

编辑 `ui_chinese_patch.py`：
```python
UI_TRANSLATIONS = {
    "Video Search and Summarization Agent": "你的产品名称",
}
```

---

## 📞 技术支持

### 常见问题

**Q: 应用品牌后页面没有变化？**
A: 
1. 强制刷新浏览器（Ctrl+F5 或 Cmd+Shift+R）
2. 清除浏览器缓存
3. 检查容器日志：`docker logs remote_vlm_deployment-via-server-1`

**Q: 机器人头像还是 NVIDIA logo？**
A: 
1. 检查是否安装 Pillow：`docker exec remote_vlm_deployment-via-server-1 pip list | grep -i pillow`
2. 手动安装：`docker exec remote_vlm_deployment-via-server-1 pip install pillow`
3. 重新运行：`bash apply_knowv_brand.sh`

**Q: 中文显示乱码？**
A: 
1. 检查容器编码：`docker exec remote_vlm_deployment-via-server-1 locale`
2. 确保使用 UTF-8 编码
3. 重启服务：`docker-compose restart via-server`

**Q: 如何恢复 NVIDIA 原版？**
A: 
```bash
docker-compose down
docker-compose up -d
# 不执行 apply_knowv_brand.sh
```

---

## 🎉 总结

通过 **KnowV 品牌定制方案**，你可以：

✅ **快速品牌化** - 一键应用完整品牌元素  
✅ **专业呈现** - 优雅的紫色主题和中文界面  
✅ **易于维护** - 脚本化部署，随时重新应用  
✅ **高度可定制** - 支持进一步个性化修改  

**KnowV = 知识 + 视频**，让 AI 视频分析更智能、更专业、更易用！🚀

