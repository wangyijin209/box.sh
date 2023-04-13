#!/bin/bash

if [ "$(grep -Eo 'ubuntu' /etc/*-release)" = "ubuntu" ]; then
  echo "检测到发行版为Ubuntu，正在使用APT安装Docker..."
  apt update
  apt install -y docker.io
  echo "Docker已安装成功！"
else
  echo "检测到发行版为Debian，请选择如何安装Docker："
  echo "1. 使用Docker官方脚本进行安装"
  echo "2. 导入Ubuntu仓库进行APT安装"

  read -p "请输入数字以选择安装方式: " choice

  case $choice in
    1)
      echo "正在使用Docker官方脚本进行安装..."
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh
      rm get-docker.sh
      echo "Docker已安装成功！"
      ;;
    2)
      echo "正在导入Ubuntu仓库进行APT安装..."
      echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      tee /etc/apt/sources.list.d/docker.list
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
      apt update
      apt install -y docker-ce docker-ce-cli containerd.io
      echo "Docker已安装成功！"
      ;;
    *)
      echo "无效的选择，请重新运行脚本并输入有效的数字。"
      ;;
  esac
fi