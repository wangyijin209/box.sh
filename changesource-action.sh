#!/bin/bash


wget -O changesource.sh https://raw.githubusercontent.com/wangyijin209/box.sh/master/changesource.sh

echo "请选择以下选项："
echo "1. 切换推荐源"
echo "2. 切换中科大源"
echo "3. 切换阿里源"
echo "4. 切换网易源"
echo "5. 切换AWS亚马逊云源"
echo "6. 还原默认源"
echo "7. 退出"

while true; do
    read -p "请输入选项编号: " choice
    case $choice in
        1)
            bash changesource.sh
            break;;
        2)
            bash changesource.sh cn
            break;;
        3)
            bash changesource.sh aliyun
            break;;
        4)
            bash changesource.sh 163
            break;;
        5)
            bash changesource.sh aws
            break;;
        6)
            bash changesource.sh restore
            break;;
        7)
            exit;;
        *)
            echo "无效选项，请重新输入。"
    esac
done
