#!/bin/bash

# GSD for Trae - 自定义安装脚本
# 用法: bash install_gsd_trae.sh <安装目录>

set -e

# 默认安装目录（当前项目下的 .trae 目录）
DEFAULT_INSTALL_DIR="$(pwd)/.trae"

# 解析命令行参数
INSTALL_DIR="$1"
if [ -z "$INSTALL_DIR" ]; then
    INSTALL_DIR="$DEFAULT_INSTALL_DIR"
    echo "未指定安装目录，使用默认目录: $DEFAULT_INSTALL_DIR"
else
    echo "使用指定安装目录: $INSTALL_DIR"
fi

GSD_REPO="https://github.com/glittercowboy/get-shit-done.git"
REPO_URL="https://github.com/Lionad-Morotar/get-shit-done-trae"

# 确保安装目录存在
mkdir -p "$INSTALL_DIR"

echo "🔧 安装 GSD for Trae..."

# 1. 下载 GSD 源文件
echo "📥 下载 GSD 源文件到 $INSTALL_DIR..."
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "📥 更新 GSD 源文件..."
    (cd "$INSTALL_DIR" && timeout 30 git reset --hard HEAD && git pull --no-rebase -q 2>&1 || echo "   ⚠️  Git pull 失败或超时，跳过更新")
else
    echo "📥 克隆 GSD 仓库..."
    # 确保安装目录不存在
    if [ -d "$INSTALL_DIR" ]; then
        # 备份现有的 rules 和 skills 目录
        BACKUP_DIR="/tmp/gsd-trae-backup-$(date +%Y%m%d%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        echo "📦 备份现有配置到 $BACKUP_DIR ..."
        
        if [ -d "$INSTALL_DIR/rules" ]; then
            cp -r "$INSTALL_DIR/rules" "$BACKUP_DIR/rules"
            echo "   ✅ rules 目录已备份"
        fi
        
        if [ -d "$INSTALL_DIR/skills" ]; then
            cp -r "$INSTALL_DIR/skills" "$BACKUP_DIR/skills"
            echo "   ✅ skills 目录已备份"
        fi
        
        # 删除安装目录
        rm -rf "$INSTALL_DIR"
    fi
    
    # 克隆 GSD 仓库
    git clone --depth 1 "$GSD_REPO" "$INSTALL_DIR" 2>&1 | tail -3 || echo "   ⚠️  克隆失败"
    
    # 恢复备份的配置
    if [ -d "$BACKUP_DIR" ]; then
        # 恢复 rules 目录
        if [ -d "$BACKUP_DIR/rules" ]; then
            if [ ! -d "$INSTALL_DIR/rules" ]; then
                mkdir -p "$INSTALL_DIR/rules"
            fi
            for file in "$BACKUP_DIR/rules/"*; do
                if [ -f "$file" ]; then
                    dest_file="$INSTALL_DIR/rules/$(basename "$file")"
                    if [ ! -f "$dest_file" ]; then
                        cp "$file" "$dest_file"
                    fi
                elif [ -d "$file" ]; then
                    dest_dir="$INSTALL_DIR/rules/$(basename "$file")"
                    if [ ! -d "$dest_dir" ]; then
                        cp -r "$file" "$dest_dir"
                    fi
                fi
            done
            echo "   ✅ rules 备份已恢复"
        fi
        
        # 恢复 skills 目录
        if [ -d "$BACKUP_DIR/skills" ]; then
            if [ ! -d "$INSTALL_DIR/skills" ]; then
                mkdir -p "$INSTALL_DIR/skills"
            fi
            for file in "$BACKUP_DIR/skills"/*; do
                if [ -f "$file" ]; then
                    dest_file="$INSTALL_DIR/skills/$(basename "$file")"
                    if [ ! -f "$dest_file" ]; then
                        cp "$file" "$dest_file"
                    fi
                elif [ -d "$file" ]; then
                    dest_dir="$INSTALL_DIR/skills/$(basename "$file")"
                    if [ ! -d "$dest_dir" ]; then
                        cp -r "$file" "$dest_dir"
                    fi
                fi
            done
            echo "   ✅ skills 备份已恢复"
        fi
        
        # 清理临时备份目录
        rm -rf "$BACKUP_DIR"
    fi
fi

# 2. 创建本地符号链接（指向安装目录）
LOCAL_GSDC_PATH="./.gsdc"
if [ -L "$LOCAL_GSDC_PATH" ]; then
    rm "$LOCAL_GSDC_PATH"
elif [ -e "$LOCAL_GSDC_PATH" ]; then
    rm -rf "$LOCAL_GSDC_PATH"
fi
ln -s "$INSTALL_DIR/commands/gsd" "$LOCAL_GSDC_PATH"
echo "🔗 创建符号链接: ./gsdc → $INSTALL_DIR/commands/gsd"

# 3. 创建 .trae/rules 目录
if [ ! -d ".trae/rules" ]; then
    echo "📁 创建 .trae/rules 目录..."
    mkdir -p ".trae/rules"
fi

# 4. 复制项目规则文档（只在文件不存在时）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_SOURCE_DIR=""

# 优先从脚本所在目录查找
if [ -d "$SCRIPT_DIR/.trae/rules" ]; then
    RULES_SOURCE_DIR="$SCRIPT_DIR/.trae/rules"
elif [ -d "$SCRIPT_DIR/.trae" ]; then
    RULES_SOURCE_DIR="$SCRIPT_DIR/.trae"
fi

# 定义需要复制的文件
RULES_FILES=("project_rules.md" "gsd-agents.md" "gsd-references.md")

# 复制或下载规则文件（只在文件不存在时）
for file in "${RULES_FILES[@]}"; do
    if [ ! -f ".trae/rules/$file" ]; then
        if [ -n "$RULES_SOURCE_DIR" ] && [ -f "$RULES_SOURCE_DIR/$file" ]; then
            # 从本地目录复制
            echo "📝 复制 $file..."
            cp "$RULES_SOURCE_DIR/$file" ".trae/rules/$file"
        else
            # 从远程仓库下载
            echo "📥 从远程仓库下载 $file..."
            curl -k -fsSL "$REPO_URL/raw/main/.trae/rules/$file" -o ".trae/rules/$file" 2>/dev/null && \
                echo "   ✅ $file 下载成功" || \
                echo "   ⚠️  $file 下载失败"
        fi
    fi
done

# 5. 确保 rules 目录存在并添加项目规则文档
if [ ! -d "$INSTALL_DIR/rules" ]; then
    mkdir -p "$INSTALL_DIR/rules"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📍 文件位置:"
echo "   GSD 源文件: $INSTALL_DIR"
echo "   命令目录: ./gsdc (符号链接)"
echo "   项目规则: $(pwd)/.trae/rules/"
echo "   技能目录: $(pwd)/.trae/skills/"
echo ""
echo "🚀 开始使用:"
echo "   在 Trae 中与 SOLO Coder 聊天时输入 /gsd:new-project"