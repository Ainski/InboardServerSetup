#!/bin/bash
set -e

echo "===== 开始全局安装 @anthropic-ai/claude-code ====="
npm install -g @anthropic-ai/claude-code

# 定义需要写入的所有环境变量内容
ENV_CONTENT=$(cat <<'EOF'
# 适配DeepSeek代理 Claude Code 环境变量
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=sk-5f3dbfd4b1834904bd208701c1973753
export ANTHROPIC_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro[1m]
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
EOF
)

BASHRC="$HOME/.bashrc"

# 检测是否已存在本段配置，防止重复追加
if grep -q "ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic" "$BASHRC"; then
    echo "检测到已存在DeepSeek相关配置，跳过写入步骤"
else
    echo -e "\n$ENV_CONTENT" >> "$BASHRC"
    echo "环境变量已追加写入 ~/.bashrc"
fi

# 重载bash配置生效
source "$BASHRC"
echo "已执行source ~/.bashrc，环境变量当前终端立即生效"

# 校验安装与环境
echo -e "\n===== 校验信息 ====="
claude --version
echo "当前ANTHROPIC_BASE_URL: $ANTHROPIC_BASE_URL"
echo "当前ANTHROPIC_MODEL: $ANTHROPIC_MODEL"