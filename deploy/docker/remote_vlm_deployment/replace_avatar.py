#!/usr/bin/env python3
"""
替换聊天机器人头像
将 NVIDIA logo 替换为简洁的 KnowV logo
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_knowv_avatar():
    """创建 KnowV 风格的聊天机器人头像"""
    
    # 创建 60x60 的头像图片
    size = 60
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 背景渐变紫色圆形
    # 使用浅紫色到深紫色的渐变
    for i in range(size):
        for j in range(size):
            # 计算距离中心的距离
            dx = i - size/2
            dy = j - size/2
            dist = (dx*dx + dy*dy) ** 0.5
            
            if dist < size/2:
                # 在圆内，根据距离计算颜色
                ratio = dist / (size/2)
                r = int(139 + (123 - 139) * ratio)  # 从 #8b5cf6 渐变
                g = int(92 + (82 - 92) * ratio)
                b = int(246 + (231 - 246) * ratio)
                img.putpixel((i, j), (r, g, b, 255))
    
    # 画一个机器人图标的简化版本
    # 机器人头部 - 白色圆角矩形
    head_left = size * 0.25
    head_top = size * 0.2
    head_right = size * 0.75
    head_bottom = size * 0.65
    draw.rounded_rectangle(
        [head_left, head_top, head_right, head_bottom],
        radius=3,
        fill=(255, 255, 255, 255)
    )
    
    # 眼睛 - 紫色圆点
    eye_y = size * 0.35
    left_eye_x = size * 0.38
    right_eye_x = size * 0.62
    eye_radius = 2
    draw.ellipse(
        [left_eye_x - eye_radius, eye_y - eye_radius, 
         left_eye_x + eye_radius, eye_y + eye_radius],
        fill=(139, 92, 246, 255)
    )
    draw.ellipse(
        [right_eye_x - eye_radius, eye_y - eye_radius,
         right_eye_x + eye_radius, eye_y + eye_radius],
        fill=(139, 92, 246, 255)
    )
    
    # 嘴巴 - 紫色弧线（微笑）
    mouth_y = size * 0.5
    draw.arc(
        [size * 0.35, mouth_y - 3, size * 0.65, mouth_y + 3],
        start=0, end=180,
        fill=(139, 92, 246, 255),
        width=1
    )
    
    # 天线 - 白色小圆点
    antenna_y = size * 0.15
    draw.ellipse(
        [size * 0.48, antenna_y - 2, size * 0.52, antenna_y + 2],
        fill=(255, 255, 255, 255)
    )
    
    # 天线线
    draw.line(
        [size * 0.5, antenna_y + 2, size * 0.5, head_top],
        fill=(255, 255, 255, 255),
        width=1
    )
    
    # 身体 - 白色圆角矩形
    body_top = head_bottom + 2
    body_bottom = size * 0.8
    draw.rounded_rectangle(
        [head_left + 3, body_top, head_right - 3, body_bottom],
        radius=2,
        fill=(255, 255, 255, 255)
    )
    
    return img

def main():
    """主函数：替换容器内的头像图片"""
    
    print("=" * 60)
    print("KnowV 头像替换工具")
    print("=" * 60)
    print()
    
    # 创建新头像
    print("[1/2] 生成 KnowV 风格头像...")
    avatar = create_knowv_avatar()
    
    # 保存到临时位置
    temp_path = "/tmp/chatbot-icon-60px.png"
    avatar.save(temp_path, "PNG")
    print(f"  ✓ 头像已生成: {temp_path}")
    
    # 查找并替换容器内的所有头像文件
    print()
    print("[2/2] 替换容器内的头像文件...")
    
    target_paths = [
        "/opt/nvidia/via/via-engine/client/assets/chatbot-icon-60px.png",
        "/opt/nvidia/via/src/client/assets/chatbot-icon-60px.png",
    ]
    
    success_count = 0
    for target_path in target_paths:
        if os.path.exists(target_path):
            try:
                avatar.save(target_path, "PNG")
                print(f"  ✓ 已替换: {target_path}")
                success_count += 1
            except Exception as e:
                print(f"  ✗ 替换失败 {target_path}: {e}")
        else:
            print(f"  - 文件不存在: {target_path}")
    
    print()
    print("=" * 60)
    if success_count > 0:
        print(f"✅ 成功替换 {success_count} 个头像文件")
        print("=" * 60)
        print()
        print("请重启服务使修改生效:")
        print("  docker-compose restart via-server")
    else:
        print("❌ 未能替换任何文件")
        print("=" * 60)
    print()

if __name__ == "__main__":
    main()

