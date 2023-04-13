#!/bin/bash

# 设置要访问的域名
domain="openai.com"

# 获取当前主机的 IP 地址
ip=$(curl -s https://checkip.amazonaws.com)

# 尝试访问 *.openai.com，并获取响应状态码
status=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "https://www.${domain}")

# 如果状态码为 200，则说明能够访问 *.openai.com
if [[ "$status" -eq 200 ]]; then
  echo "能够访问 *ChatGPT"
else
  echo "无法访问 ChatGPT"
fi

# 尝试访问 openai-gpt-neo-customer-prod.azurewebsites.net，并获取响应状态码
status=$(curl -o /dev/null --silent --head --write-out '%{http_code}\n' "https://openai-gpt-neo-customer-prod.azurewebsites.net")

# 如果状态码为 403 或 429，则说明当前主机的 IP 地址被封禁了
if [[ "$status" -eq 403 ]] || [[ "$status" -eq 429 ]]; then
  echo "当前主机的 IP 地址 $ip 已被封禁"
else
  echo "当前主机的 IP 地址 $ip 未被封禁"
fi