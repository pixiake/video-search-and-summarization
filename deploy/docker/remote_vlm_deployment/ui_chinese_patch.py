#!/usr/bin/env python3
"""
VSS UI 中文化补丁
将此文件挂载到容器中并在启动时执行
"""

import sys
import os

# UI 文本映射表 - 全面版
UI_TRANSLATIONS = {
    # ============ 主界面标题 ============
    "Video Search and Summarization Agent": "KnowV 视频智能分析系统",
    "VIDEO FILE SUMMARIZATION & Q&A": "视频文件摘要与问答",
    "LIVE STREAM SUMMARIZATION": "实时流分析",
    "IMAGE FILE SUMMARIZATION & Q&A": "图片文件摘要与问答",
    
    # ============ 按钮文字 ============
    "Summarize": "生成摘要",
    "Ask": "提问",
    "Reset Chat": "重置对话",
    "Delete File": "删除文件",
    "Show Parameters": "显示参数",
    "Hide Parameters": "隐藏参数",
    "Start": "开始",
    "Stop": "停止",
    "Upload": "上传",
    "Submit": "提交",
    "Clear": "清除",
    "Add Alert": "添加告警",
    "Generate Highlight": "生成高光",
    
    # ============ Tab 标签页 ============
    "CHAT": "对话",
    "SUMMARIES": "摘要",
    "ALERTS": "告警",
    "Create Alerts": "创建告警",
    "PARAMETERS": "参数",
    "VIDEO EVENT SUMMARY": "视频事件摘要",
    "RESPONSE": "回复",
    
    # ============ 输入框标签 ============
    "Ask a question": "输入问题",
    "Video ID (Optional)": "视频ID（可选）",
    "Alert Name": "告警名称",
    "Enter your question here...": "在此输入您的问题...",
    "Upload a video file": "上传视频文件",
    "Select a file": "选择文件",
    
    # ============ 复选框 ============
    "Enable Summarization": "启用摘要生成",
    "Enable Chat": "启用对话",
    "Enable Audio": "启用音频分析",
    "Enable Dense Caption": "启用详细描述",
    "Enable Chat History": "启用对话历史",
    "Enable CV Metadata": "启用计算机视觉元数据",
    
    # ============ 折叠面板 ============
    "Summarize Parameters": "摘要参数",
    "Chat Parameters": "对话参数",
    "Alert Parameters": "告警参数",
    "Notification Parameters": "通知参数",
    "Advanced Parameters": "高级参数",
    "VLM Parameters": "视觉语言模型参数",
    
    # ============ 参数标签 ============
    "Temperature": "温度",
    "Summarize Temperature": "摘要温度",
    "Chat Temperature": "对话温度",
    "Notification Temperature": "通知温度",
    "Max Tokens": "最大令牌数",
    "Max New Tokens": "最大新令牌数",
    "Top P": "Top-P采样",
    "Top K": "Top-K采样",
    "Seed": "随机种子",
    "Chunk Duration": "分块时长",
    "Chunk Overlap Duration": "分块重叠时长",
    "Frames per Chunk": "每块帧数",
    "Num Frames per Chunk": "每块帧数",
    "VLM Input Width": "VLM输入宽度",
    "VLM Input Height": "VLM输入高度",
    "Batch Size": "批处理大小",
    "Summarize Batch Size": "摘要批处理大小",
    "RAG Batch Size": "RAG批处理大小",
    "RAG Top K": "RAG Top-K",
    
    # ============ 下拉选项 ============
    "No chunking": "不分块",
    "Select chunking strategy": "选择分块策略",
    
    # ============ 表格列名 ============
    "Alert Name": "告警名称",
    "Event(s) [comma separated]": "事件（逗号分隔）",
    
    # ============ 状态消息 ============
    "Processing...": "处理中...",
    "Completed": "已完成",
    "Failed": "失败",
    "Loading...": "加载中...",
    "Ready": "就绪",
    "Connected": "已连接",
    "Disconnected": "已断开",
    "Summarization failed": "摘要生成失败",
    
    # ============ 提示信息 ============
    "Please upload a video first": "请先上传视频",
    "Please enter a question": "请输入问题",
    "Processing your request...": "正在处理您的请求...",
    "Video uploaded successfully": "视频上传成功",
    "Error occurred": "发生错误",
    "Select/Upload video to summarize": "选择/上传视频以生成摘要",
    "Select/Upload image(s) to summarize": "选择/上传图片以生成摘要",
    
    # ============ 不要翻译以下内容（它们可能是 API 字段值） ============
    # 注意：不翻译单个词如 "video", "image" 等，因为它们可能是代码中的枚举值
    # 只翻译完整的用户界面文本
}

def patch_file(file_path):
    """给文件打中文化补丁 - 安全版本，只替换 UI 文本"""
    if not os.path.exists(file_path):
        print(f"文件不存在: {file_path}")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        changes_made = 0
        
        # 替换所有文本 - 按长度从长到短排序，避免部分匹配问题
        sorted_translations = sorted(UI_TRANSLATIONS.items(), key=lambda x: len(x[0]), reverse=True)
        
        for english, chinese in sorted_translations:
            # 只在 UI 相关的上下文中替换
            # 1. label= 属性（Gradio UI 组件）
            pattern1 = f'label="{english}"'
            if pattern1 in content:
                count_before = content.count(pattern1)
                content = content.replace(pattern1, f'label="{chinese}"')
                changes_made += count_before
            
            pattern2 = f"label='{english}'"
            if pattern2 in content:
                count_before = content.count(pattern2)
                content = content.replace(pattern2, f"label='{chinese}'")
                changes_made += count_before
            
            # 2. value= 属性（只用于按钮等 UI 文本，不是数据值）
            # 需要检查是否是 gr.Button 或 gr.update 的 value
            pattern3 = f'gr.Button("{english}"'
            if pattern3 in content:
                content = content.replace(pattern3, f'gr.Button("{chinese}"')
                changes_made += 1
            
            pattern4 = f"gr.Button('{english}'"
            if pattern4 in content:
                content = content.replace(pattern4, f"gr.Button('{chinese}'")
                changes_made += 1
            
            # 3. gr.update(value="...") 用于按钮文本
            pattern5 = f'gr.update(interactive=True, value="{english}")'
            if pattern5 in content:
                content = content.replace(pattern5, f'gr.update(interactive=True, value="{chinese}")')
                changes_made += 1
                
            pattern6 = f'gr.update(interactive=False, value="{english}")'
            if pattern6 in content:
                content = content.replace(pattern6, f'gr.update(interactive=False, value="{chinese}")')
                changes_made += 1
            
            # 4. title= 属性（页面标题）
            pattern7 = f'title="{english}"'
            if pattern7 in content:
                content = content.replace(pattern7, f'title="{chinese}"')
                changes_made += 1
            
            # 5. gr.Tab() 标签页
            pattern8 = f'gr.Tab("{english}")'
            if pattern8 in content:
                content = content.replace(pattern8, f'gr.Tab("{chinese}")')
                changes_made += 1
            
            # 6. gr.Accordion() 折叠面板
            pattern9 = f'gr.Accordion("{english}"'
            if pattern9 in content:
                content = content.replace(pattern9, f'gr.Accordion("{chinese}"')
                changes_made += 1
            
            # 7. placeholder= 属性
            pattern10 = f'placeholder="{english}"'
            if pattern10 in content:
                content = content.replace(pattern10, f'placeholder="{chinese}"')
                changes_made += 1
            
            # 8. info= 属性（提示信息）
            pattern11 = f'info="{english}"'
            if pattern11 in content:
                content = content.replace(pattern11, f'info="{chinese}"')
                changes_made += 1
        
        # 如果内容被修改，写回文件
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✓ 已中文化: {file_path} ({changes_made} 处修改)")
            return True
        else:
            print(f"- 无需修改: {file_path}")
            return False
            
    except Exception as e:
        print(f"✗ 处理失败 {file_path}: {e}")
        return False

def main():
    """主函数：批量处理UI文件"""
    files_to_patch = [
        "/opt/nvidia/via/via-engine/via_demo_client.py",
        "/opt/nvidia/via/via-engine/client/summarization.py",
        "/opt/nvidia/via/via-engine/client/rtsp_stream.py",
        "/opt/nvidia/via/via-engine/client/ui_utils.py",
        "/opt/nvidia/via/src/via_demo_client.py",
        "/opt/nvidia/via/src/client/summarization.py",
        "/opt/nvidia/via/src/client/rtsp_stream.py",
        "/opt/nvidia/via/src/client/ui_utils.py",
    ]
    
    print("=" * 60)
    print("VSS UI 中文化补丁")
    print("=" * 60)
    
    success_count = 0
    for file_path in files_to_patch:
        if patch_file(file_path):
            success_count += 1
    
    print("=" * 60)
    print(f"完成！成功中文化 {success_count}/{len(files_to_patch)} 个文件")
    print("=" * 60)

if __name__ == "__main__":
    main()

