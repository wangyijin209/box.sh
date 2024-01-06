#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "请使用root用户运行!"
  exit
fi
colors=("\033[0m" "\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m" "\033[37m")
color=${colors[$RANDOM % ${#colors[@]}]}
echo -e "${color}正在安装必要软件>>>loading......\033[0m"
apt install figlet  lolcat -y
echo "==========================================================================="
echo "Powered  by  yijin" | figlet | lolcat
echo "==========================================================================="
echo ""
echo "======================================="
echo -e "${color}脚本为原创或收录\033[0m"
echo "Github: https://github.com/wangyijin209" | lolcat
echo "======================================="

function run_script() {

  curl -O $1
  

  chmod +x $(basename $1)


  ./$(basename $1)
  

  rm $(basename $1)
}

echo "请选择要运行的脚本（输入数字，输入 q 退出）："
select script_num in "Docker安装脚本" "acme申请脚本" "TikTok检测" "流媒体解锁检测" "ChatGPT检测" "x-ui原版脚本" "甬哥x-ui脚本" "甬哥warp脚本" "swap" "ipv4/6优先级调整一键脚本" "LNMP(请使用screen)" "换源" "Bench" "退出"
do
  case $script_num in
    "Docker安装脚本")
      run_script "https://raw.githubusercontent.com/wangyijin209/box.sh/master/docker.sh"
      break
      ;;
    "acme申请脚本")
      run_script "https://raw.githubusercontent.com/wangyijin209/box.sh/master/acme.sh"
      break
      ;;
    "TikTok检测")
      run_script "https://raw.githubusercontent.com/lmc999/TikTokCheck/main/tiktok.sh"
      break
      ;;
    "流媒体解锁检测")
      run_script "https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh"
      break
      ;;
    "ChatGPT检测")
      run_script "https://raw.githubusercontent.com/missuo/OpenAI-Checker/main/openai.sh"
      break
      ;;

    "FranzKafkaYu x-ui")
      run_script "https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh"
      break
      ;;
    "x-ui原版脚本")
      run_script "https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh"
      break
      ;;
    "甬哥x-ui脚本")
      run_script "https://gitlab.com/rwkgyg/x-ui-yg/raw/main/install.sh"
      break
      ;;
    "甬哥warp脚本")
      run_script "https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh"
      break
      ;;
    "fscarmen Sing-box 全家桶")
      run_script "https://raw.githubusercontent.com/fscarmen/sing-box/main/sing-box.sh"
      break
      ;;
    "fscarmen ArgoX")
      run_script "https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh"
      break
      ;;      
    "swap")
      run_script "https://raw.githubusercontent.com/BlueSkyXN/ChangeSource/master/swap.sh"
      break
      ;;
    "ipv4/6优先级调整一键脚本")
      run_script "https://raw.githubusercontent.com/BlueSkyXN/ChangeSource/master/ipv.sh"
      break
      ;;
    "LNMP(请使用screen)")
      run_script "https://raw.githubusercontent.com/wangyijin209/box.sh/master/lnmp.org.sh"
      break
      ;;
    "换源")
      run_script "https://raw.githubusercontent.com/wangyijin209/box.sh/master/changesource-action.sh"
      break
      ;;
    "Bench")
      run_script "https://raw.githubusercontent.com/wangyijin209/box.sh/master/bench.sh"
      break
      ;;
    "退出")
      break
      ;;
    *)
      echo "请选择有效的数字或输入 q 退出。"
      ;;
  esac
done

echo "感谢使用本脚本！" | lolcat
