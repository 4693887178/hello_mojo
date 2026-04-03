#!/usr/bin/env python3
"""
OpenSpace MCP 配置安装脚本
用于将 OpenSpace 配置添加到 ~/.trae-cn-server/data/Machine/mcp.json
"""

import json
import os
import sys
from pathlib import Path

# 配置文件路径
MCP_CONFIG_PATH = Path.home() / ".trae-cn-server" / "data" / "Machine" / "mcp.json"

# OpenSpace 配置
OPAMESPACE_CONFIG = {
    "OpenSpace": {
        "command": "/home/zhou/hello_mojo/trae_cn_78/.venv/bin/openspace-mcp",
        "args": [],
        "env": {
            "OPENSPACE_HOST_SKILL_DIRS": "/home/zhou/hello_mojo/trae_cn_78/.trae/skills",
            "OPENSPACE_WORKSPACE": "/home/zhou/hello_mojo/trae_cn_78/OpenSpace",
            "OPENSPACE_API_KEY": "sk-EI3bFdy-T9fOdS8nnFt5R_AUeHUNyBoiTGplXm-q2_0"
        },
        "toolTimeout": 600
    }
}


def backup_config(config_path: Path) -> Path:
    """备份现有配置文件"""
    if config_path.exists():
        backup_path = config_path.with_suffix(".json.backup")
        backup_path.write_text(config_path.read_text(encoding="utf-8"), encoding="utf-8")
        print(f"✓ 已备份原配置文件到：{backup_path}")
        return backup_path
    return None


def install_openspace_config():
    """安装 OpenSpace MCP 配置"""
    print("=" * 60)
    print("OpenSpace MCP 配置安装脚本")
    print("=" * 60)
    
    # 检查配置文件是否存在
    if not MCP_CONFIG_PATH.exists():
        print(f"✗ 错误：配置文件不存在：{MCP_CONFIG_PATH}")
        print("  请确认 Trae CN 是否已安装并运行过")
        sys.exit(1)
    
    print(f"\n✓ 找到配置文件：{MCP_CONFIG_PATH}")
    
    # 备份现有配置
    backup_config(MCP_CONFIG_PATH)
    
    # 读取现有配置
    try:
        with open(MCP_CONFIG_PATH, "r", encoding="utf-8") as f:
            config = json.load(f)
    except json.JSONDecodeError as e:
        print(f"✗ 错误：无法解析 JSON 配置文件：{e}")
        sys.exit(1)
    
    # 确保 mcpServers 存在
    if "mcpServers" not in config:
        config["mcpServers"] = {}
        print("✓ 创建 mcpServers 配置项")
    
    # 检查是否已存在 OpenSpace 配置
    if "OpenSpace" in config["mcpServers"]:
        print("⚠ 警告：OpenSpace 配置已存在")
        overwrite = input("是否覆盖现有配置？(y/n): ").strip().lower()
        if overwrite != "y":
            print("已取消安装")
            sys.exit(0)
    
    # 添加 OpenSpace 配置
    config["mcpServers"]["OpenSpace"] = OPAMESPACE_CONFIG["OpenSpace"]
    print("✓ 已添加 OpenSpace 配置")
    
    # 保存新配置
    with open(MCP_CONFIG_PATH, "w", encoding="utf-8") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    
    print(f"✓ 配置已保存到：{MCP_CONFIG_PATH}")
    
    # 验证配置
    print("\n" + "=" * 60)
    print("安装完成！已添加以下配置：")
    print("=" * 60)
    print(json.dumps(OPAMESPACE_CONFIG, indent=2, ensure_ascii=False))
    print("\n✓ 请重启 Trae CN 以应用新配置")
    print("=" * 60)


if __name__ == "__main__":
    install_openspace_config()
