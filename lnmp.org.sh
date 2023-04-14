#!/bin/bash

colors=("\033[0m" "\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m" "\033[37m")
color=${colors[$RANDOM % ${#colors[@]}]}
echo -e "${color}欢迎使用LNMP无人值守安装脚本！\033[0m"
echo -e "${color}使用方法详见：https://lnmp.org/install.html\033[0m"
echo -e "${color}请使用screen运行，如果已经在screen里请继续，否则请退出脚本进入screen后再次运行\033[0m"
echo -e "${color}1. 继续\033[0m"
echo -e "${color}2. 退出\033[0m"

read -p "请输入数字以选择选项: " choice

case $choice in
  1)
    echo "正在下载LNMP安装脚本..."
    wget http://soft.vpser.net/lnmp/lnmp1.9.tar.gz -cO lnmp1.9.tar.gz && tar zxf lnmp1.9.tar.gz && cd lnmp1.9 && ./install.sh lnmp
    ;;
  2)
    echo "退出安装脚本..."
    exit 0
    ;;
  *)
    echo "无效的选择，请重新运行脚本并输入有效的数字。"
    ;;
esac