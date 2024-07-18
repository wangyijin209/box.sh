#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m' # 恢复终端默认颜色

# 获取IP
get_ip(){
    public_ip=$(curl -s https://api.ipify.org)

    # 检查是否成功获取到公网IP地址
    if [ -z "$public_ip" ]; then
        echo -e "${RED}无法获取公网IP地址。${RESET}"
        exit 1
    fi
    echo -e "${GREEN}你的公网IP地址是: $public_ip${RESET}"
}

# 查找 sing-box 最新版本
get_latest_version(){
    # GitHub API URL for the latest release of sing-box
    API_URL="https://api.github.com/repos/SagerNet/sing-box/releases/latest"

    # 获取最新版本的发布信息
    response=$(curl -s $API_URL)

    # 检查响应是否为空
    if [ -z "$response" ]; then
        echo -e "${RED}无法获取最新版本的发布信息${RESET}"
        exit 1
    fi

    # 从响应中解析版本号
    version=$(echo $response | grep -oP '"tag_name": "\K(.*?)(?=")')
    version_later="${version#v}" 
    URL="https://github.com/SagerNet/sing-box/releases/download/$version/sing-box_${version_later}_linux_amd64.deb"
    FILE_NAME="sing-box_${version_later}_linux_amd64.deb"
    
}

# 安装 sing-box
install_sing_box() {
    echo -e "${RED}目前仅支持Debian系 ${RESET}"
    apt install uuid-runtime -y
    echo -e "${GREEN}即将进行Reality-tcp的搭建 ${RESET}"

    # 使用 curl 下载文件
    echo "正在下载 ${FILE_NAME}..."
    curl -L -o $FILE_NAME $URL

    # 检查下载是否成功
    if [ $? -eq 0 ]; then
        echo "下载成功: ${FILE_NAME}"
    else
        echo "下载失败"
        exit 1
    fi

    # 解压 deb 文件
    EXTRACT_DIR="sing-box_extracted"
    mkdir -p $EXTRACT_DIR
    dpkg-deb -x $FILE_NAME $EXTRACT_DIR
    # 检查解压是否成功
    if [ $? -eq 0 ]; then
        echo "解压成功: ${EXTRACT_DIR}"
    else
        echo "解压失败"
        exit 1
    fi
    # 将二进制可执行文件移动到/etc
    mkdir -p /etc/sing-box
    mv $EXTRACT_DIR/usr/bin/sing-box /etc/sing-box
    rm -R $EXTRACT_DIR && rm $FILE_NAME
}

# 写入sing-box.service
write_sing_box_service() {
	cat <<EOF > /etc/systemd/system/sing-box.service
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
ExecStart=sing-box run -C /etc/sing-box/conf/
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
    output=$(/etc/sing-box/sing-box generate reality-keypair)
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
    echo -e "${YELLOW}vless://$UUID@$public_ip:$port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=$public_key&type=tcp&headerType=none#$tag
${RESET}"
    echo "vless://$UUID@$public_ip:$port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=addons.mozilla.org&fp=chrome&pbk=$public_key&type=tcp&headerType=none#$tag" > /etc/sing-box/.info
}

# 用户输入'3'输出的客户端链接
output_client2(){
    cat /etc/sing-box/.info
}

# 安装 sing-box 主函数
sing-box() {    
    get_ip
    get_latest_version
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
    rm /etc/systemd/system/sing-box.service

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
echo -e "${YELLOW}3. 查看节点链接${RESET}"
read -p $'\033[0;33m请输入数字以选择: \033[0m' choice

case $choice in
    1)
        sing-box
        ;;
    2)
        uninstall_sing-box
        ;;
    3)
        output_client2
        ;;
    *)
        echo -e "${RED}无效的选择，请输入1或2.${RESET}"
        ;;
esac
