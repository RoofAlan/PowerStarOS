#!/bin/bash

# exp file
export exp=$(pwd)
PID_S=$$
echo $PID_S > .pid_s
source $exp/kernel/syscall.sh
CONFIG_FILE=$exp/etc/etc.conf
read_config() {
        local section="$1"
        local key="$2"
        # 使用grep查找指定的section和key，然后使用awk提取值
        local value=$(grep "^$key" "$CONFIG_FILE" | awk -F "=" '{print $2}')
        echo "$value"
}
home_dir=$exp$(read_config SHELL HOME | tr -d " ")
# Login/Sign

# Sign

while [ "$(cat etc/act 2>/dev/null)" = "" ] || [ ! -f "etc/act" ]; do
	echo "Sign User"
	read -p "Username: " s_username
	[ -z "$s_username" ] && s_username="root" && echo "Default = root"
	read -s -p "Password: " s_passwd
	echo
	read -p "Hostname: " s_hostname
	echo "$s_username:$s_passwd" | base64 >> etc/act
	echo "$s_hostname" > etc/hostname
	break
done

while true; do
	while [ "$l" != "1" ]; do
		echo "Login User"
		read -p "Username: " l_username
		read -s -p "Password: " l_passwd
		echo
		[ -z "$l_username" ] && echo "Missing some errors, please try again" && break
		l_line=1
		while true; do
			line_d=$(awk "NR==$l_line" etc/act)
			[ -z "$line_d" ] && break
			if [ "$(echo $l_username:$l_passwd | base64)" = "$line_d" ]; then
				l=1
				user=$l_username
				break
			else
				((l_line++))
			fi
		done
	done
	[ "$l" = "1" ] && break
done


hostname=$(cat etc/hostname)
#echo $exp
[ -f "etc/weli" ] && cat etc/weli 
cd $home_dir
while true; do
	if ! pwd | grep -q "$exp"; then
		cd $exp
	fi
	safe_exp=$(printf '%s' "$exp" | sed 's/[\/&]/\\&/g')
	fl_g=$(echo $(pwd) | sed "s/^$safe_exp//")
	[ -z "$fl_g" ] && fl_g="/"
	if [ "$fl_g" = "$(read_config SHELL HOME | tr -d ' ')" ]; then
		fl_g="~"
	fi
	read -e -p "$(printf "$cmderr\033[32m$user@$hostname \033[33m$fl_g\033[32m $ \033[0m")" command_in
	# read -e command_in
	head_cmd=$(echo $command_in | awk '{print $1}')
	cmd_t=$(echo $command_in | awk '{print $2}')
	[[ "$cmd_t" == "/"* ]] && cmd_t=$exp$cmd_t 
	case $head_cmd in
		"exit"|"poweroff")
			exit
		;;
		cd)
			if [ ! -z "$cmd_t" ]; then
				if [ -d "$cmd_t" ]; then
					cd $cmd_t
					cmderr=""
				else
					echo -e "\033[31m$(echo $cmd_t | sed "s/^$safe_exp//"): No such file or directory"
					cmderr="\033[31m1|"
				fi
			else
				cd $home_dir
				cmderr=""
			fi
		;;
		"pwd")
			if [ "$fl_g" != "~" ]; then
				echo "$fl_g"
			else
				echo "$(read_config SHELL HOME)"
			fi
			cmderr=""
		;;
		"")
			echo a &>/dev/null
		;;
		*)
			if ! echo $command_in | grep -q " "; then
				other_arg=""
			else
				other_arg=${command_in#* }
			fi
			if [ -f $exp/bin/$head_cmd ]; then
				bash $exp/bin/$head_cmd $other_arg
				cmd_back=$?
				if [ ! $cmd_back -eq 0 ]; then
					cmderr="\033[31m$cmd_back|"
				else
					cmderr=""
				fi
			else
				echo -e "\033[31m$head_cmd: Command not found."
				cmderr="\033[31m127|"
			fi
		;;
	esac
done
