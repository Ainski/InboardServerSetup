#!/bin/bash

# Script to install Miniconda and configure mirrors

set -e  # Exit on any error

# Function to print header
print_header() {
    echo "==========================================="
    echo "  Miniconda 安装与镜像配置脚本"
    echo "  Miniconda Installation & Mirror Setup"
    echo "==========================================="
}

# Function to download with fallback
download_installer() {
    local url="$1"
    local output="$2"
    local temp_file="${output}.tmp"
    
    echo "正在从 $url 下载..."
    echo "Downloading from $url..."
    
    curl -L -o "$temp_file" "$url" --connect-timeout 10 --max-time 300
    
    if [[ $? -ne 0 ]]; then
        rm -f "$temp_file"
        return 1
    fi
    
    # 检查是否包含 403 Forbidden
    if grep -q "<title>403 Forbidden</title>" "$temp_file" 2>/dev/null; then
        echo "检测到 403 Forbidden，下载失败。"
        echo "Detected 403 Forbidden, download failed."
        rm -f "$temp_file"
        return 1
    fi
    
    # 检查文件大小（应该大于1MB才是有效的安装包）
    local file_size=$(stat -c%s "$temp_file" 2>/dev/null || stat -f%z "$temp_file" 2>/dev/null)
    if [[ -n "$file_size" && "$file_size" -lt 1048576 ]]; then
        echo "下载的文件太小（${file_size}字节），可能无效。"
        echo "Downloaded file is too small (${file_size} bytes), may be invalid."
        rm -f "$temp_file"
        return 1
    fi
    
    mv "$temp_file" "$output"
    return 0
}

# Check if conda is already installed
if command -v conda &> /dev/null; then
    echo "检测到 conda 已安装。"
    echo "Conda is already installed."
    conda --version
    
    # 即使已安装，也配置或更新镜像源
    echo "正在配置/更新镜像源..."
    echo "Configuring/Updating mirrors..."
    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
    conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
    conda config --set show_channel_urls yes
    echo "镜像源配置完成。"
    echo "Mirror configuration complete."
    exit 0
fi

print_header

echo "未找到 conda。正在为您安装 Miniconda..."
echo "Conda is not installed. Installing Miniconda for you..."
echo ""

# Determine OS and architecture
OS=$(uname -s)
ARCH=$(uname -m)

# Define URLs for different sources
declare -A TUNA_URLS
declare -A ZJU_URLS

if [[ "$OS" == "Linux" ]]; then
    TUNA_URLS["x86_64"]="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    ZJU_URLS["x86_64"]="https://mirrors.zju.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh"
elif [[ "$OS" == "Darwin" ]]; then
    if [[ "$ARCH" == "arm64" ]]; then
        TUNA_URLS["arm64"]="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        ZJU_URLS["arm64"]="https://mirrors.zju.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
    else
        TUNA_URLS["x86_64"]="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        ZJU_URLS["x86_64"]="https://mirrors.zju.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
    fi
else
    echo "不支持的操作系统: $OS"
    echo "Unsupported operating system: $OS"
    exit 1
fi

CONDA_INSTALLER="miniconda_installer.sh"

# Download logic
if [[ -f "$CONDA_INSTALLER" ]]; then
    echo "检测到已存在的安装包: $CONDA_INSTALLER，直接使用..."
    echo "Found existing installer: $CONDA_INSTALLER, using it..."
else
    echo "未找到安装包，开始下载..."
    echo "No installer found, starting download..."
    
    TUNA_URL="${TUNA_URLS[$ARCH]}"
    ZJU_URL="${ZJU_URLS[$ARCH]}"
    
    if [[ -z "$TUNA_URL" || -z "$ZJU_URL" ]]; then
        echo "错误: 找不到适合当前架构（$ARCH）的下载链接。"
        echo "Error: No download URL found for architecture ($ARCH)."
        exit 1
    fi
    
    echo "尝试从清华源下载..."
    echo "Trying Tsinghua mirror..."
    if download_installer "$TUNA_URL" "$CONDA_INSTALLER"; then
        echo "从清华源下载成功！"
        echo "Download from Tsinghua mirror successful!"
    else
        echo "从清华源下载失败，切换到浙大源..."
        echo "Download from Tsinghua mirror failed, switching to ZJU mirror..."
        if download_installer "$ZJU_URL" "$CONDA_INSTALLER"; then
            echo "从浙大源下载成功！"
            echo "Download from ZJU mirror successful!"
        else
            echo "所有镜像源下载均失败。"
            echo "All mirror downloads failed."
            exit 1
        fi
    fi
fi

# Install Miniconda
echo "正在安装 Miniconda..."
echo "Installing Miniconda..."
bash "$CONDA_INSTALLER" -b -p "$HOME/miniconda3"

if [[ $? -ne 0 ]]; then
    echo "Miniconda 安装失败。"
    echo "Miniconda installation failed."
    exit 1
fi

# Initialize conda
echo "正在初始化 conda..."
echo "Initializing conda..."
"$HOME/miniconda3/bin/conda" init bash

# Add conda to current shell session
export PATH="$HOME/miniconda3/bin:$PATH"

# Configure mirrors (THIS IS THE CRITICAL PART THAT WAS MISSING)
echo "正在配置 conda 和 pip 镜像源..."
echo "Configuring conda and pip mirrors..."

# Configure pip mirror
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Configure conda mirrors
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/linux-64/
conda config --set show_channel_urls yes

echo "镜像源配置完成。"
echo "Mirror configuration complete."

# Verify installation
if command -v conda &> /dev/null; then
    echo ""
    echo "==========================================="
    echo "  Miniconda 安装成功！"
    echo "  Miniconda installed successfully!"
    echo "==========================================="
    echo "版本信息 (Version):"
    conda --version
    echo ""
    echo "已配置的镜像源 (Configured mirrors):"
    echo "  pip: https://pypi.tuna.tsinghua.edu.cn/simple"
    echo "  conda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/"
    echo ""
    echo "请重新启动终端或运行以下命令使更改生效:"
    echo "Please restart your terminal or run: source ~/.bashrc"
    echo ""
    echo "常用命令 (Common commands):"
    echo "  conda create -n myenv python=3.10  # 创建环境"
    echo "  conda activate myenv               # 激活环境"
    echo "  conda deactivate                   # 停用环境"
else
    echo "警告: conda 命令不可用，可能需要重新启动终端。"
    echo "Warning: conda command is not available, you may need to restart your terminal."
    exit 1
fi