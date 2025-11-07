#!/bin/bash

# Script to help users configure a new conda environment through Q&A

set -e  # Exit on any error

# Function to print header
print_header() {
    echo "==========================================="
    echo "  欢迎使用 Conda 环境配置助手"
    echo "  Conda Environment Setup Assistant"
    echo "==========================================="
}

# Function to print section separators
print_separator() {
    echo "==========================================="
}

# Function to validate environment name
validate_env_name() {
    local name="$1"
    # Check for valid characters (alphanumeric, underscore, hyphen)
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "错误: 环境名称只能包含字母、数字、下划线和连字符。"
        echo "Error: Environment name can only contain letters, numbers, underscores, and hyphens."
        return 1
    fi
    # Check length (conda has issues with very long names)
    if [[ ${#name} -gt 50 ]]; then
        echo "错误: 环境名称太长（最多50个字符）。"
        echo "Error: Environment name is too long (max 50 characters)."
        return 1
    fi
    return 0
}

# Function to check if conda environment exists
env_exists() {
    local env_name="$1"
    conda info --envs | grep -q "^$env_name\s"
}

# Function to get user input with validation
get_user_input() {
    local prompt="$1"
    local default_value="$2"
    local input
    
    if [[ -n "$default_value" ]]; then
        read -p "$prompt (默认: $default_value): " input
        if [[ -z "$input" ]]; then
            input="$default_value"
        fi
    else
        read -p "$prompt: " input
    fi
    
    echo "$input"
}

# Function to display and get Python version selection
get_python_version() {
    echo ""
    echo "请选择 Python 版本:"
    echo "Choose Python version:"
    echo " 1) Python 3.9"
    echo " 2) Python 3.10" 
    echo " 3) Python 3.11"
    echo " 4) Python 3.12"
    echo " 5) Python 3.13"
    echo " 6) 其他版本 (手动输入)"
    echo " 7) 使用最新版本"
    
    while true; do
        read -p "请输入选项 (1-7): " python_choice
        case $python_choice in
            1) echo "3.9"; return ;;
            2) echo "3.10"; return ;;
            3) echo "3.11"; return ;;
            4) echo "3.12"; return ;;
            5) echo "3.13"; return ;;
            6) 
                local version
                version=$(get_user_input "请输入 Python 版本 (例如 3.9.7)" "")
                if [[ -n "$version" ]]; then
                    echo "$version"
                    return
                else
                    echo "错误: Python 版本不能为空。"
                    echo "Error: Python version cannot be empty."
                fi
                ;;
            7) echo "3.x"; return ;;
            *)
                echo "无效选项，请重新输入。"
                echo "Invalid option, please try again."
                ;;
        esac
    done
}

# Function to get package list
get_packages() {
    echo ""
    echo "您可以通过以下方式安装包："
    echo "You can install packages in the following ways:"
    echo " 1) 输入包名称 (例如: numpy pandas requests)"
    echo " 2) 提供环境文件路径 (例如: environment.yml)"
    echo " 3) 跳过安装额外包"
    
    while true; do
        read -p "请选择 (1-3): " pkg_choice
        case $pkg_choice in
            1) 
                read -p "请输入要安装的包 (用空格分隔): " packages
                echo "$packages"
                return
                ;;
            2)
                read -p "请输入环境文件路径: " env_file
                if [[ -f "$env_file" ]]; then
                    echo "file:$env_file"
                    return
                else
                    echo "错误: 文件不存在。"
                    echo "Error: File does not exist."
                fi
                ;;
            3) 
                echo ""
                return
                ;;
            *)
                echo "无效选项，请重新输入。"
                echo "Invalid option, please try again."
                ;;
        esac
    done
}

# Function to confirm creation
confirm_creation() {
    local env_name="$1"
    local py_version="$2"
    local packages="$3"
    
    echo ""
    print_separator
    echo "  配置摘要"
    echo "  Configuration Summary"
    print_separator
    echo "环境名称 (Environment name): $env_name"
    echo "Python 版本 (Python version): $py_version"
    if [[ -n "$packages" ]]; then
        if [[ "$packages" == file:* ]]; then
            echo "环境文件 (Environment file): ${packages#file:}"
        else
            echo "额外包 (Extra packages): $packages"
        fi
    else
        echo "额外包 (Extra packages): 无 (None)"
    fi
    print_separator
    
    while true; do
        read -p "确认创建环境 (y/N)? " -n 1 -r
        echo
        case $REPLY in
            [Yy]* ) return 0 ;;
            [Nn]* ) return 1 ;;
            * ) echo "请输入 y 或 n。" ;;
        esac
    done
}

# Function to create the conda environment
create_environment() {
    local env_name="$1"
    local py_version="$2"
    local packages="$3"
    
    echo ""
    echo "正在创建环境 '$env_name' 使用 Python $py_version..."
    echo "Creating environment '$env_name' with Python $py_version..."
    
    if [[ -n "$packages" ]]; then
        if [[ "$packages" == file:* ]]; then
            # Use environment file
            local env_file="${packages#file:}"
            conda env create -n "$env_name" -f "$env_file"
        else
            # Install packages directly
            conda create -y -n "$env_name" python="$py_version" $packages
        fi
    else
        # Create environment without additional packages
        conda create -y -n "$env_name" python="$py_version"
    fi
}

# Function to display success message
display_success() {
    local env_name="$1"
    
    echo ""
    print_separator
    echo "  环境创建成功!"
    echo "  Environment created successfully!"
    print_separator
    echo "环境名称 (Environment name): $env_name"
    echo ""
    echo "激活环境命令 (Activation command): conda activate $env_name"
    echo "停用环境命令 (Deactivation command): conda deactivate"
    echo "删除环境命令 (Removal command): conda env remove -n $env_name"
    echo "查看所有环境 (List all environments): conda env list"
    echo "==========================================="
}

# Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "未找到 conda。正在为您安装 Miniconda..."
    echo "Conda is not installed. Installing Miniconda for you..."
    echo ""
    
    # Determine OS and architecture
    OS=$(uname -s)
    ARCH=$(uname -m)
    
    if [[ "$OS" == "Linux" ]]; then
        CONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    elif [[ "$OS" == "Darwin" ]]; then
        if [[ "$ARCH" == "arm64" ]]; then
            CONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            CONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
    else
        echo "不支持的操作系统: $OS"
        echo "Unsupported operating system: $OS"
        exit 1
    fi
    
    # Download and install Miniconda
    CONDA_INSTALLER="miniconda_installer.sh"
    echo "正在从镜像源下载 Miniconda..."
    echo "Downloading Miniconda from mirror..."
    curl -o "$CONDA_INSTALLER" -L "$CONDA_URL"
    
    if [[ $? -ne 0 ]]; then
        echo "下载失败。正在尝试备用源..."
        echo "Download failed. Trying backup source..."
        if [[ "$OS" == "Linux" ]]; then
            curl -o "$CONDA_INSTALLER" -L "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
        elif [[ "$OS" == "Darwin" ]]; then
            if [[ "$ARCH" == "arm64" ]]; then
                curl -o "$CONDA_INSTALLER" -L "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
            else
                curl -o "$CONDA_INSTALLER" -L "https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
            fi
        fi
        
        if [[ $? -ne 0 ]]; then
            echo "无法下载 Miniconda 安装程序。"
            echo "Unable to download Miniconda installer."
            rm -f "$CONDA_INSTALLER"
            exit 1
        fi
    fi
    
    echo "正在安装 Miniconda..."
    echo "Installing Miniconda..."
    bash "$CONDA_INSTALLER" -b -p "$HOME/miniconda3"
    
    if [[ $? -ne 0 ]]; then
        echo "Miniconda 安装失败。"
        echo "Miniconda installation failed."
        rm -f "$CONDA_INSTALLER"
        exit 1
    fi
    
    # Clean up installer
    rm -f "$CONDA_INSTALLER"
    
    # Initialize conda
    echo "正在初始化 conda..."
    echo "Initializing conda..."
    "$HOME/miniconda3/bin/conda" init bash
    
    # Add conda to current shell session
    export PATH="$HOME/miniconda3/bin:$PATH"
    
    # Verify that conda command is available
    if command -v conda &> /dev/null; then
        echo "Miniconda 安装并初始化成功！"
        echo "Miniconda installed and initialized successfully!"
    else
        echo "警告: conda 命令不可用，可能需要重新启动终端或手动添加到 PATH。"
        echo "Warning: conda command is not available, you may need to restart your terminal or manually add to PATH."
        exit 1
    fi
else
    echo "检测到 conda 已安装。"
    echo "Conda is detected on your system."
fi

# 配置pip镜像
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 配置conda 镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/linux-64/
conda config --set show_channel_urls yes

# Main script execution starts here
print_header

# Ask for environment name
echo ""
while true; do
    env_name=$(get_user_input "请输入新的环境名称 (例如: myproject)" "")
    if [[ -z "$env_name" ]]; then
        echo "错误: 环境名称不能为空。"
        echo "Error: Environment name cannot be empty."
        continue
    fi
    
    if ! validate_env_name "$env_name"; then
        continue
    fi
    
    # Check if environment already exists
    if env_exists "$env_name"; then
        echo "警告: 环境 '$env_name' 已存在。"
        echo "Warning: Environment '$env_name' already exists."
        read -p "是否要继续创建 (y/N)? " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            break
        else
            continue
        fi
    else
        break
    fi
done

# Get Python version
python_version=$(get_python_version)

# Get additional packages
packages=$(get_packages)

# Confirmation step
if ! confirm_creation "$env_name" "$python_version" "$packages"; then
    echo "操作已取消。"
    echo "Operation cancelled."
    exit 0
fi

# Create the conda environment
if create_environment "$env_name" "$python_version" "$packages"; then
    # Check if environment was created successfully
    if env_exists "$env_name"; then
        display_success "$env_name"
    else
        echo "错误: 环境创建失败。"
        echo "Error: Environment creation failed."
        exit 1
    fi
else
    echo "错误: 环境创建失败。"
    echo "Error: Environment creation failed."
    exit 1
fi

echo ""
echo "感谢使用 Conda 环境配置助手!"
echo "Thank you for using the Conda Environment Setup Assistant!"