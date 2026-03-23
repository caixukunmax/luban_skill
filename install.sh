#!/usr/bin/env bash
# Luban Config Editor Skill 安装脚本 (Linux/macOS Bash)
# 用法: ./install.sh [--target project|user] [--project-path /path/to/proj]

set -e

# 默认参数
TARGET="project"
PROJECT_PATH=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --target|-t)
            TARGET="$2"
            shift 2
            ;;
        --project-path|-p)
            PROJECT_PATH="$2"
            shift 2
            ;;
        --help|-h)
            echo "Luban Config Editor Skill 安装脚本"
            echo ""
            echo "用法:"
            echo "  ./install.sh                              # 安装到当前项目"
            echo "  ./install.sh --target user                # 安装到用户目录（全局）"
            echo "  ./install.sh --target project --project-path /path/to/proj"
            echo ""
            echo "参数:"
            echo "  --target, -t      安装目标: project (项目级) 或 user (用户级)"
            echo "  --project-path, -p  项目路径（仅 --target project 时有效）"
            echo ""
            echo "示例:"
            echo "  ./install.sh                                    # 安装到当前项目"
            echo "  ./install.sh --target user                       # 安装到用户目录"
            echo "  ./install.sh -t project -p /home/user/mygame     # 安装到指定项目"
            exit 0
            ;;
        *)
            echo "未知参数: $1"
            echo "使用 --help 查看帮助"
            exit 1
            ;;
    esac
done

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SOURCE="$SCRIPT_DIR/.qoder/skills/luban-config-editor"

# 检查 skill 源目录
if [ ! -d "$SKILL_SOURCE" ]; then
    echo "错误: 找不到 skill 源目录: $SKILL_SOURCE"
    exit 1
fi

# 确定目标路径
if [ "$TARGET" = "user" ]; then
    DEST_PATH="$HOME/.qoder/skills/luban-config-editor"
    echo "安装模式: 用户级（全局）"
else
    if [ -n "$PROJECT_PATH" ]; then
        TARGET_PROJECT="$PROJECT_PATH"
    else
        TARGET_PROJECT="$SCRIPT_DIR"
    fi
    DEST_PATH="$TARGET_PROJECT/.qoder/skills/luban-config-editor"
    echo "安装模式: 项目级"
    echo "目标项目: $TARGET_PROJECT"
fi

echo "目标路径: $DEST_PATH"
echo ""

# 检查是否已存在
if [ -d "$DEST_PATH" ]; then
    read -p "Skill 已存在，是否覆盖? (y/N): " OVERWRITE
    if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
        echo "安装已取消"
        exit 0
    fi
    rm -rf "$DEST_PATH"
fi

# 创建目标目录
DEST_PARENT="$(dirname "$DEST_PATH")"
if [ ! -d "$DEST_PARENT" ]; then
    mkdir -p "$DEST_PARENT"
fi

# 复制 skill
echo "正在复制 skill 文件..."
cp -r "$SKILL_SOURCE" "$DEST_PATH"

# 显示安装结果
echo ""
echo "========================================"
echo "  安装成功!"
echo "========================================"
echo ""
echo "Skill 路径: $DEST_PATH"
echo ""

# 检查 Python 依赖
echo "检查依赖..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1)
    echo "Python: $PYTHON_VERSION"
    
    if python3 -c "import openpyxl" 2>/dev/null; then
        echo "openpyxl: 已安装"
    else
        echo "openpyxl: 未安装"
        echo "请运行: pip install openpyxl"
    fi
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1)
    echo "Python: $PYTHON_VERSION"
    
    if python -c "import openpyxl" 2>/dev/null; then
        echo "openpyxl: 已安装"
    else
        echo "openpyxl: 未安装"
        echo "请运行: pip install openpyxl"
    fi
else
    echo "Python: 未安装"
    echo "请安装 Python 3.8+ 后再使用此 skill"
fi

echo ""
echo "使用方式:"
echo "  在 Qoder 中直接描述需求，AI 会自动调用此 skill"
echo "  或手动执行: python $DEST_PATH/scripts/luban_helper.py --help"
echo ""
