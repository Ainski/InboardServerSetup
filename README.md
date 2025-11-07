# Inboard Server Setup

本仓库包含用于搭建 Node.js 和 Qwen Code 开发环境的 Shell 脚本，针对中国用户优化了镜像配置。

## 概述

项目提供自动化脚本来完成以下任务：
- 安装 Node 版本管理器 (NVM) 并配置国内镜像
- 安装 Node.js 22 版本
- 配置 npm 使用国内镜像源
- 安装和设置 Qwen Code
- 通过问答方式配置 conda 环境并设置国内镜像源
- 自动安装 Miniconda（如果系统未安装）

## 前置要求

- 类 Unix 环境（Linux/macOS）并支持 bash
- curl 用于下载文件
- 网络连接

## 脚本说明

### `node.sh`
安装 NVM、配置 Node.js 22 版本，并设置 npm 镜像源配置。

功能特性：
- 从国内镜像（Gitee）下载 NVM
- 安装 Node.js 22 版本
- 配置 npm 使用国内镜像源以提高下载速度

### `qwenCode.sh`
在 Node.js 安装完成后全局安装 Qwen Code CLI 工具。

### `pythonAndConda.sh`
通过问答方式帮助用户配置新的 conda 环境。

功能特性：
- 检测 conda 是否已安装
- 提供交互式问答界面配置环境
- 支持选择 Python 版本（3.9-3.13及自定义版本）
- 支持安装额外包或通过环境文件创建环境
- 配置国内镜像源（清华源）以提高下载速度
- 包含环境名称验证和重复检查
- 详细的使用说明和成功提示

## 使用方法

1. 确保脚本具有可执行权限：
   ```bash
   chmod +x node.sh qwenCode.sh pythonAndConda.sh
   ```

2. 运行 Node.js 安装脚本：
   ```bash
   ./node.sh
   ```

3. Node.js 安装完成后，安装 Qwen Code：
   ```bash
   ./qwenCode.sh
   ```

4. 配置 conda 环境（需要已安装 conda）：
   ```bash
   ./pythonAndConda.sh
   ```

## 配置详情

- Node.js 版本：22（最新 LTS 版本）
- NPM 镜像源：https://registry.npmmirror.com/
- NVM 镜像：https://gitee.com/RubyMetric/nvm-cn/raw/main/install.sh

## 故障排除

如果遇到问题：

1. 检查是否具有执行脚本的适当权限
2. 验证 curl 是否已安装：`which curl`
3. 确保环境中可用 bash
4. 如果安装失败，尝试直接使用 `bash` 命令运行脚本：
   ```bash
   bash node.sh
   bash qwenCode.sh
   ```