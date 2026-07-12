#!/bin/bash
# Trae Toolkit 一键部署脚本
# 
# ⚠️  重要：必须在系统终端中运行！
#    macOS: Terminal.app / iTerm2
#    Windows: Git Bash / PowerShell (需先装 Git)
#    Trae IDE 内置终端有沙箱限制，无法写入 ~/.trae-cn/ 和 ~/.trae/
# 用法: bash deploy.sh

set -e

# ============================
# 平台检测
# ============================
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        MSYS*)      echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

OS=$(detect_os)

# 检测是否在 Trae 沙箱终端内运行
if [ -n "$TRAE_RUNTIME" ] || [ -n "$ICUBE_APP_ROOT" ]; then
    echo "❌ 检测到 Trae IDE 内置终端。"
    echo ""
    echo "   Trae 内置终端有沙箱限制，无法写入 ~/.trae-cn/skills/"
    echo "   请在系统终端中运行此脚本。"
    echo ""
    if [ "$OS" = "windows" ]; then
        echo "   Windows 用户请打开 Git Bash 后运行："
        echo "     cd \$(cygpath -u \"%USERPROFILE%\")/Documents/trae_projects/trae-toolkit"
        echo "     bash deploy.sh"
    else
        echo "   macOS 用户请打开 Terminal.app 后运行："
        echo "     cd ~/Documents/trae_projects/trae-toolkit"
        echo "     bash deploy.sh"
    fi
    echo ""
    exit 1
fi

# 路径设置（Git Bash on Windows 中 $HOME 映射到 /c/Users/xxx）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TRAE_CN_SKILLS="$HOME/.trae-cn/skills"
TRAE_USER_RULES="$HOME/.trae/user_rules"
TRAE_ROLES_MEMORY="$HOME/.trae/roles-memory"

echo "=== Trae Toolkit 部署开始 ==="
echo "  平台: $OS"
echo ""

# 1. 部署 Skills
echo "[1/3] 部署 Skills 到 $TRAE_CN_SKILLS ..."
mkdir -p "$TRAE_CN_SKILLS"
for skill_dir in "$SCRIPT_DIR"/skills/*; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        dest="$TRAE_CN_SKILLS/$skill_name"
        if [ -d "$dest" ]; then
            # ⚠️ 不加 -n：覆盖 SKILL.md 以应用角色迭代更新
            cp "$skill_dir/SKILL.md" "$dest/"
            echo "  🔄 $skill_name (已更新)"
        else
            cp -r "$skill_dir" "$TRAE_CN_SKILLS/"
            echo "  ✅ $skill_name (新增)"
        fi
    fi
done

# 2. 部署 User Rules
echo ""
echo "[2/3] 部署 Rules 到 $TRAE_USER_RULES ..."
mkdir -p "$TRAE_USER_RULES"
for rule_file in "$SCRIPT_DIR"/user_rules/*.md; do
    if [ -f "$rule_file" ]; then
        # ⚠️ 不加 -n：覆盖以应用规则更新
        cp "$rule_file" "$TRAE_USER_RULES/"
        echo "  ✅ $(basename "$rule_file")"
    fi
done

# 3. 部署共享 Memory（保留用户自定义文件）
echo ""
echo "[3/3] 部署共享 Memory 到 $TRAE_ROLES_MEMORY ..."
if [ -d "$TRAE_ROLES_MEMORY" ]; then
    # -rn: 递归 + 不覆盖目标已有文件（保护用户自己在知识库里加的内容）
    cp -rn "$SCRIPT_DIR"/roles-memory/* "$TRAE_ROLES_MEMORY/"
    echo "  ✅ roles-memory (已有内容保留)"
else
    cp -r "$SCRIPT_DIR"/roles-memory "$TRAE_ROLES_MEMORY"
    echo "  ✅ roles-memory (全新安装)"
fi

echo ""
echo "=== 部署完成 ==="
echo ""

# 统计（跨平台兼容）
skill_count=$(ls "$TRAE_CN_SKILLS" 2>/dev/null | grep -c 'trae-')
rule_count=$(ls "$TRAE_USER_RULES"/*.md 2>/dev/null | wc -l | tr -d '[:space:]')

echo "已安装:"
echo "  Skills: ${skill_count} 个角色"
echo "  Rules:  ${rule_count} 个"
echo "  Memory: ~/.trae/roles-memory/"
echo ""
echo "💡 在新项目中使用:"
echo "   对 Agent 说：\"初始化 .trae\""
