# 安装nvm

curl -o- https://gitee.com/RubyMetric/nvm-cn/raw/main/install.sh | bash
chmod +x ~/.nvm/nvm.sh
source ~/.bashrc

# 检查nvm

if [ -z "$(command -v nvm)" ]; then
  echo "nvm not installed"
  exit 1
fi

# 安装node
echo 'export NVM_NODEJS_ORG_MIRROR=https://npmmirror.com/mirrors/node' >> ~/.bashrc
source ~/.bashrc

nvm install 22

# 检查node

if [ -z "$(command -v node)" ]; then
  echo "node not installed"
  exit 1
fi

# 设置npm镜像
npm config set registry https://registry.npmmirror.com/

