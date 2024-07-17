#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m' # 恢复终端默认颜色

# 根据发行版运行相应的安装脚本


install_sing_box() {
    echo -e "${RED} 目前仅支持Debian系 ${RESET}"
    bash <(curl -fsSL https://sing-box.app/deb-install.sh)
    apt install uuid-runtime -y
    echo -e "${GREEN}即将进行Reality-tcp的搭建 ${RESET}"
}

# 写入sing-box.service
write_sing_box_service() {
	cat <<EOF > /lib/systemd/system/sing-box.service
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target

[Service]
User=root
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
WorkingDirectory=/etc/sing-box
ExecStart=/usr/bin/sing-box run -C /etc/sing-box/conf/
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target

EOF
}

# 输入端口号
input_port(){
    read -p $'\e[0;33m(1/2)  请输入端口号(必须在 100 - 65520 之间): \e[0m' port
    # 检查输入是否为空
    if [ -z "$port" ]; then
        echo -e "${RED}端口号不能为空。${RESET}"
        exit 1
    fi
    # 检查输入是否为有效的端口号（100-65535）
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 100 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}无效的端口号。请输入100到65535之间的数字。${RESET}"
        exit 1
    fi
}

# 输入节点名称
input_tag(){
    read -p $'\e[0;33m(2/2)  请输入节点名称: \e[0m' tag
}

# 生成UUID
generate_uuid(){
    echo -e "${RED}将自动生成UUID${RESET}"
    UUID=$(uuidgen)
}

# 生成Reality公钥和私钥
generate_key(){
    output=$(/usr/bin/sing-box generate reality-keypair)
    private_key=$(echo "$output" | grep -oP '(?<=PrivateKey: ).*')
    public_key=$(echo "$output" | grep -oP '(?<=PublicKey: ).*')

    if [ -z "$public_key" ] || [ -z "$private_key" ]; then
        echo -e "${RED}生成公钥和私钥失败。${RESET}"
        exit 1
    fi
}


# 写入xtls-reality_inbounds.json
write_json() {
    mkdir -p /etc/sing-box/conf/
    cat <<EOF > /etc/sing-box/conf/xtls-reality_inbounds.json
{
    "inbounds":[
        {
            "type":"vless",
            "sniff":true,
            "sniff_override_destination":true,
            "tag":"$tag",
            "listen":"::",
            "listen_port":$port,
            "users":[
                {
                    "uuid":"$UUID",
                    "flow":"xtls-rprx-vision"
                }
            ],
            "tls":{
                "enabled":true,
                "server_name":"addons.mozilla.org",
                "reality":{
                    "enabled":true,
                    "handshake":{
                        "server":"addons.mozilla.org",
                        "server_port":443
                    },
                    "private_key":"$private_key",
                    "short_id":[
                        ""
                    ]
                }
            },
            "multiplex":{
                "enabled":true,
                "padding":true,
                "brutal":{
                    "enabled":true,
                    "up_mbps":1000,
                    "down_mbps":1000
                }
            }
        }
    ]
}

EOF

}

# 启动 sing-box服务
start_sing-box(){
    systemctl daemon-reload
    systemctl enable sing-box
    systemctl restart sing-box
    echo -e "${GREEN}安装完成。 sing-box 服务已启动${RESET}"
}

# 输出客户端链接

output_client(){
    echo -e "${GREEN}客户端链接如下：${RESET}"
    echo -e "${YELLOW}vless://$UUID@$IP:$port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=$public_key&type=tcp&headerType=none#$tag
${RESET}"
}

# 安装 sing-box 主函数
sing-box() {    
    install_sing_box
    write_sing_box_service
    input_port
    input_tag
    generate_uuid
    generate_key
    write_json
    start_sing-box
    output_client
}

# 卸载 sing-box 主函数
uninstall_sing-box(){
    # 停止并禁用服务
    systemctl stop sing-box
    systemctl disable sing-box

    # 删除systemd服务文件
    rm /lib/systemd/system/sing-box.service

    # 重新加载systemd服务
    systemctl daemon-reload

    # 删除gfw文件夹
    rm -rf /etc/sing-box
    echo -e "${RED}卸载完成。 sing-box 服务已经全部移除。${RESET}"
}

# 提示用户选择操作
echo "请选择操作："
echo -e "${YELLOW}1. 安装 sing-box${RESET}"
echo -e "${YELLOW}2. 卸载 sing-box${RESET}"
read -p $'\033[0;33m请输入1或2: \033[0m' choice

case $choice in
    1)
        sing-box
        ;;
    2)
        uninstall_sing-box
        ;;
    *)
        echo -e "${RED}无效的选择，请输入1或2.${RESET}"
        ;;
esac