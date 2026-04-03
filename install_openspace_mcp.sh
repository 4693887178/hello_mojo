#!/bin/bash
# OpenSpace MCP 配置安装脚本 (Bash 版本)
# 用于将 OpenSpace 配置添加到 ~/.trae-cn-server/data/Machine/mcp.json

set -e

MCP_CONFIG_PATH="$HOME/.trae-cn-server/data/Machine/mcp.json"

echo "============================================================"
echo "OpenSpace MCP 配置安装脚本"
echo "============================================================"

# 检查配置文件是否存在
if [ ! -f "$MCP_CONFIG_PATH" ]; then
    echo "✗ 错误：配置文件不存在：$MCP_CONFIG_PATH"
    echo "  请确认 Trae CN 是否已安装并运行过"
    exit 1
fi

echo ""
echo "✓ 找到配置文件：$MCP_CONFIG_PATH"

# 备份现有配置
if [ -f "$MCP_CONFIG_PATH" ]; then
    cp "$MCP_CONFIG_PATH" "${MCP_CONFIG_PATH}.backup"
    echo "✓ 已备份原配置文件到：${MCP_CONFIG_PATH}.backup"
fi

# 使用 Python 更新 JSON (因为 bash 处理 JSON 不方便)
python3 << 'PYTHON_SCRIPT'
import json
import os
from pathlib import Path

MCP_CONFIG_PATH = Path.home() / ".trae-cn-server" / "data" / "Machine" / "mcp.json"

OPAMESPACE_CONFIG = {
    "command": "/home/zhou/hello_mojo/trae_cn_78/.venv/bin/openspace-mcp",
    "args": [],
    "env": {
        "OPENSPACE_HOST_SKILL_DIRS": "/home/zhou/hello_mojo/trae_cn_78/.trae/skills",
        "OPENSPACE_WORKSPACE": "/home/zhou/hello_mojo/trae_cn_78/OpenSpace",
        "OPENSPACE_API_KEY": "sk-EI3bFdy-T9fOdS8nnFt5R_AUeHUNyBoiTGplXm-q2_0"
    },
    "toolTimeout": 600
}

# 读取配置
with open(MCP_CONFIG_PATH, "r", encoding="utf-8") as f:
    config = json.load(f)

# 确保 mcpServers 存在
if "mcpServers" not in config:
    config["mcpServers"] = {}

# 检查是否已存在
if "OpenSpace" in config["mcpServers"]:
    print("⚠ 警告：OpenSpace 配置已存在，将覆盖")

# 添加配置
config["mcpServers"]["OpenSpace"] = OPAMESPACE_CONFIG

# 保存
with open(MCP_CONFIG_PATH, "w", encoding="utf-8") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)

print("✓ 已添加 OpenSpace 配置")
PYTHON_SCRIPT

echo ""
echo "✓ 配置已保存到：$MCP_CONFIG_PATH"
echo ""
echo "============================================================"
echo "安装完成！"
echo "============================================================"
echo ""
echo "✓ 请重启 Trae CN 以应用新配置"
echo ""
