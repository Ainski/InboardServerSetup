# 需要说明的是，这里的脚本只是为了提供国内下载源跳过一些包的漫长下载

# 这里也提供了docker下载的内容

sudo apt update
sudo apt install curl

# 一键安装脚本
curl -fsSL https://get.docker.com -o install-docker.sh

sudo sh install-docker.sh --mirror Aliyun


# 启用 Docker 服务，设置为开机自动启动
sudo systemctl enable docker

# 永久换源换国内源

sudo tee /etc/docker/daemon.json <<-'EOF'
{
    "registry-mirrors": [
        "https://docker.nju.edu.cn",
        "https://docker.1ms.run",
        "https://mirror.ccs.tencentyun.com",
        "https://dockerproxy.link",
        "https://docker.xuanyuan.me",
        "https://docker.m.daocloud.io",
        "https://hub-mirror.c.163.com"
    ]
}
EOF

# 预下载cuda 
docker pull nvidia/cuda:12.8.0-devel-ubuntu22.04

# 国内源下载 改用uv
docker pull m.daocloud.io/ghcr.io/astral-sh/uv:0.8.0
docker tag m.daocloud.io/ghcr.io/astral-sh/uv:0.8.0 ghcr.io/astral-sh/uv:0.8.0