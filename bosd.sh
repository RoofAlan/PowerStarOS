
clear
err_title="[        ERROR        ]"
err_msg="[ SYSTEM CANNOT START ]"
width=$(stty size | cut -d' ' -f2-)
height=$(($(stty size | awk '{print $1}') / 2 - 2))
while true; do
	echo -e "\e[$height;$(($width / 2 - ${#err_title}))H\033[36;7m${err_title}\033[0m"
	echo -e "\e[$(($height + 1));$(($width / 2 - ${#err_msg}))H\033[36;7m${err_msg}\033[0m"
	read -n 1 -s
done
