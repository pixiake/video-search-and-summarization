#!/usr/bin/env python3
"""
VSS UI 主题切换脚本
支持：紫色主题、深色主题、原始主题
"""

import json
import sys
import os
import re

# 主题文件路径
THEME_JSON_PATH = "/opt/nvidia/via/via-engine/client/assets/kaizen-theme.json"
APP_BAR_PATH = "/opt/nvidia/via/via-engine/client/assets/app_bar.html"
CSS_PATH = "/opt/nvidia/via/via-engine/client/assets/kaizen-theme.css"

# 主题配色定义
THEMES = {
    "purple": {
        "name": "浅紫色主题",
        "primary": {
            "primary_50": "#f5f3ff",
            "primary_100": "#ede9fe",
            "primary_200": "#ddd6fe",
            "primary_300": "#c4b5fd",
            "primary_400": "#a78bfa",
            "primary_500": "#8b5cf6",
            "primary_600": "#7c3aed",
            "primary_700": "#6d28d9",
            "primary_800": "#5b21b6",
            "primary_900": "#4c1d95",
            "primary_950": "#2e1065"
        },
        "secondary": {
            "secondary_50": "#eff6ff",
            "secondary_100": "#dbeafe",
            "secondary_200": "#bfdbfe",
            "secondary_300": "#93c5fd",
            "secondary_400": "#60a5fa",
            "secondary_500": "#3b82f6",
            "secondary_600": "#2563eb",
            "secondary_700": "#1d4ed8",
            "secondary_800": "#1e40af",
            "secondary_900": "#1e3a8a",
            "secondary_950": "#172554"
        },
        "button_primary_background_fill": "#8b5cf6",
        "button_primary_background_fill_dark": "#8b5cf6",
        "button_primary_background_fill_hover": "#7c3aed",
        "button_primary_background_fill_hover_dark": "#7c3aed",
        "button_primary_border_color": "#8b5cf6",
        "button_primary_border_color_dark": "#8b5cf6",
        "logo_fill": "#8B5CF6",
        "color_accent": "#8b5cf6",
        "color_accent_soft": "#ddd6fe"
    },
    "dark": {
        "name": "科技黑主题",
        "primary": {
            "primary_50": "#f0f9ff",
            "primary_100": "#e0f2fe",
            "primary_200": "#bae6fd",
            "primary_300": "#7dd3fc",
            "primary_400": "#38bdf8",
            "primary_500": "#0ea5e9",
            "primary_600": "#0284c7",
            "primary_700": "#0369a1",
            "primary_800": "#075985",
            "primary_900": "#0c4a6e",
            "primary_950": "#082f49"
        },
        "secondary": {
            "secondary_50": "#ecfeff",
            "secondary_100": "#cffafe",
            "secondary_200": "#a5f3fc",
            "secondary_300": "#67e8f9",
            "secondary_400": "#22d3ee",
            "secondary_500": "#06b6d4",
            "secondary_600": "#0891b2",
            "secondary_700": "#0e7490",
            "secondary_800": "#155e75",
            "secondary_900": "#164e63",
            "secondary_950": "#083344"
        },
        "background_fill_primary": "#0f172a",
        "background_fill_primary_dark": "#0f172a",
        "background_fill_secondary": "#1e293b",
        "body_text_color": "#e2e8f0",
        "body_text_color_dark": "#e2e8f0",
        "block_label_text_color": "#cbd5e1",
        "block_label_text_color_dark": "#cbd5e1",
        "button_primary_background_fill": "#0ea5e9",
        "button_primary_background_fill_dark": "#0ea5e9",
        "button_primary_background_fill_hover": "#0284c7",
        "button_primary_background_fill_hover_dark": "#0284c7",
        "button_primary_border_color": "#0ea5e9",
        "button_primary_border_color_dark": "#0ea5e9",
        "logo_fill": "#0EA5E9",
        "color_accent": "#0ea5e9",
        "color_accent_soft": "#bae6fd"
    },
    "original": {
        "name": "NVIDIA 原始主题",
        "primary": {
            "primary_50": "#e4fabe",
            "primary_100": "#caf087",
            "primary_200": "#b6e95d",
            "primary_300": "#9fd73d",
            "primary_400": "#76b900",
            "primary_500": "#659f00",
            "primary_600": "#538300",
            "primary_700": "#4d6721",
            "primary_800": "#253a00",
            "primary_900": "#1d2e00",
            "primary_950": "#172400"
        },
        "button_primary_background_fill": "#76b900",
        "button_primary_background_fill_dark": "#76b900",
        "button_primary_background_fill_hover": "#659f00",
        "button_primary_background_fill_hover_dark": "#659f00",
        "button_primary_border_color": "#76b900",
        "button_primary_border_color_dark": "#76b900",
        "logo_fill": "#76B900",
        "color_accent": "#76b900",
        "color_accent_soft": "#caf087"
    }
}

def apply_theme(theme_name):
    """应用指定主题"""
    if theme_name not in THEMES:
        print(f"❌ 未知主题: {theme_name}")
        print(f"可用主题: {', '.join(THEMES.keys())}")
        return False
    
    theme = THEMES[theme_name]
    print(f"正在应用主题: {theme['name']}")
    
    # 1. 修改 theme.json
    try:
        with open(THEME_JSON_PATH, 'r', encoding='utf-8') as f:
            theme_config = json.load(f)
        
        # 更新颜色
        for key, value in theme.items():
            if key == 'name':
                continue
            if isinstance(value, dict):
                theme_config['theme'].update(value)
            else:
                theme_config['theme'][key] = value
        
        with open(THEME_JSON_PATH, 'w', encoding='utf-8') as f:
            json.dump(theme_config, f, indent=2, ensure_ascii=False)
        
        print(f"  ✓ 已更新主题配置文件")
    except Exception as e:
        print(f"  ✗ 更新主题配置失败: {e}")
        return False
    
    # 2. 替换整个 app_bar.html - 移除 NVIDIA Logo
    try:
        # 使用自定义的无品牌 Header
        custom_header = f'''<!--
# Custom Header - NVIDIA Logo Removed
-->

<div
     style="height: 3rem; display: flex; flex-direction: row; justify-content: space-between; align-items: stretch; box-sizing: border-box; background-color: rgb(5, 5, 5);">
    <a href="/" style="align-items: center; box-sizing: content-box; display: flex; flex-direction: row; height: 24px; padding: 12px;
    font-family: Roboto, sans-serif;
text-decoration-color: rgb(32, 32, 32);
text-decoration-line: none;
text-decoration-style: solid;
text-decoration-thickness: auto;">
        <!-- 自定义 Logo：简单的图标或文字 -->
        <svg viewBox="0 0 40 40" style="display: block; height: 32px; margin-right: 12px; overflow: hidden;">
            <g fill="none" fill-rule="evenodd">
                <!-- 简洁的视频图标 -->
                <rect x="5" y="10" width="30" height="20" rx="3" stroke="{theme["logo_fill"]}" stroke-width="2.5" fill="none"/>
                <polygon points="16,17 16,23 24,20" fill="{theme["logo_fill"]}"/>
                <circle cx="28" cy="14" r="2" fill="{theme["logo_fill"]}"/>
            </g>
        </svg>
        <span
              style="font-family: Roboto, sans-serif; font-size: 21.84px; font-weight: 500; text-transform: uppercase; color: rgb(250, 250, 250); letter-spacing: 1px;">
            视频智能分析系统</span>
    </a>
</div>'''
        
        with open(APP_BAR_PATH, 'w', encoding='utf-8') as f:
            f.write(custom_header)
        
        print(f"  ✓ 已替换为自定义 Header（无 NVIDIA Logo）")
    except Exception as e:
        print(f"  ✗ 更新 Header 失败: {e}")
        return False
    
    # 3. 修改 CSS（如果是深色主题）
    if theme_name == "dark":
        try:
            with open(CSS_PATH, 'r', encoding='utf-8') as f:
                css_content = f.read()
            
            # 替换背景色
            css_content = re.sub(
                r'background-color:\s*#f5f5f5\s*!important',
                'background-color: #0f172a !important',
                css_content
            )
            css_content = re.sub(
                r'background-color:\s*#ffffff\s*!important',
                'background-color: #1e293b !important',
                css_content
            )
            
            with open(CSS_PATH, 'w', encoding='utf-8') as f:
                f.write(css_content)
            
            print(f"  ✓ 已应用深色主题 CSS")
        except Exception as e:
            print(f"  ✗ 更新 CSS 失败: {e}")
    
    print(f"\n✅ 主题应用成功！请重启服务以查看效果。")
    return True

def show_themes():
    """显示所有可用主题"""
    print("="*60)
    print("可用主题：")
    print("="*60)
    for key, theme in THEMES.items():
        print(f"\n  [{key}] - {theme['name']}")
        if 'button_primary_background_fill' in theme:
            print(f"    主色: {theme['button_primary_background_fill']}")
        if 'logo_fill' in theme:
            print(f"    Logo: {theme['logo_fill']}")
    print("\n"+"="*60)

def main():
    if len(sys.argv) < 2:
        print("用法: python3 change_theme.py <主题名>")
        print("\n主题选项:")
        print("  purple  - 浅紫色主题（优雅专业）")
        print("  dark    - 科技黑主题（酷炫深色）")
        print("  original - NVIDIA 原始主题")
        print("\n示例:")
        print("  python3 change_theme.py purple")
        print("  python3 change_theme.py dark")
        sys.exit(1)
    
    theme_name = sys.argv[1].lower()
    
    if theme_name == "list":
        show_themes()
        sys.exit(0)
    
    if apply_theme(theme_name):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()

