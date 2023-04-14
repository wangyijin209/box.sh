#!/bin/bash

# 安装 acme.sh
curl https://get.acme.sh | sh

# 检查是否已有证书
cert_path="/root/.acme.sh/$domain/fullchain.cer"
if [[ -f "$cert_path" ]]; then
  echo "已有证书：$cert_path"
  read -p "是否删除？（y/n）" confirm
  if [[ "$confirm" == "y" ]]; then
    acme.sh --remove -d $domain
    rm -rf "/root/acme-yj"
    echo "已删除证书：$cert_path"
  else
    exit
  fi
fi


mkdir -p /root/acme-yj


echo "CPU 信息：$(lscpu | grep 'Model name')"
echo "IP 地址：$(hostname -I)"
echo "虚拟化信息：$(systemd-detect-virt)"


echo "请选择申请模式："
echo "1. 直接 80 端口申请模式"
echo "2. Cloudflare DNS API 模式"
read -p "请输入数字（1 或 2）：" mode

if [[ "$mode" == "1" ]]; then
  # 直接 80 端口申请模式
  read -p "请输入域名：" domain
  /root/.acme.sh/acme.sh --issue --standalone -d $domain -d www.$domain --cert-file /root/acme-yj/cert.pem --key-file /root/acme-yj/key.pem --fullchain-file /root/acme-yj/fullchain.pem
elif [[ "$mode" == "2" ]]; then
  # Cloudflare DNS API 模式
  read -p "请输入 Cloudflare API Key：" api_key
  read -p "请输入 Cloudflare 邮箱：" email
  read -p "请输入域名：" domain
  /root/.acme.sh/acme.sh --issue --dns dns_cf -d $domain -d www.$domain --cert-file /root/acme-yj/cert.pem --key-file /root/acme-yj/key.pem --fullchain-file /root/acme-yj/fullchain.pem --dns-dns_cf --dns-dns_cf_key $api_key --dns-dns_cf_email $email
else
  echo "输入有误，请重新运行脚本。"
  exit 1
fi


echo "证书储存路径：/root/acme-yj"
echo "证书文件名：/root/acme-yj/cert.pem"
echo "私钥文件名：/root/acme-yj/key.pem"
echo "完整证书文件名：fullchain.pem"

