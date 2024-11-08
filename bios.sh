#!/bin/bash

clear
CONFIG_FILE="./bios.conf"
read_config() {
	local section="$1"
	local key="$2"
	# 使用grep查找指定的section和key，然后使用awk提取值
	local value=$(grep "^$key" "$CONFIG_FILE" | awk -F "=" '{print $2}')
	echo "$value"
}

print_line() {
	width=$(stty size | awk '{print $2}')
	for ((i=0;i<$width;i++)); do
		echo -ne "\033[7m \033[0m"
	done
}

echo -n "BIOS SETTING: "
[ ! -f "$CONFIG_FILE" ] && echo "Not found" && exit 1
sec_boot=$(read_config BOOT BOOT_CHECK)
echo "Found"
echo "Secure boot: $sec_boot"

echo "Loading..."
for ((i=0;i<40;i++)); do
	lea="$lea "
done
for ((i=0;i<40;i++)); do
	prg="$prg="
	lea=${lea:1}
	echo -ne "\r[$prg$lea] $((i * 2 + 22))%"
	sleep 0.05
done
echo

echo -n "Load Chinese Font..."
sleep 0.05
echo Done
echo -n "寻找内核..."
[ ! -f "kernel/system.sh" ] && echo "Failed" && echo "错误: 内核丢失" && exit 1

echo "Done"
if [ "$sec_boot" = " true" ]; then
	echo -n "校验内核..."
	[ "$(read_config "BOOT" "SHA_CODE")" != "$(sha256sum ./kernel/system.sh | awk '{print $1}')" ] && echo "Failed" && echo "内核校验失败，您无法安全的启动" && exit 1
	echo "Done"
	# echo -e "$(sha256sum ./kernel/system.sh | awk '{print $1}')\n$(read_config "BOOT" "SHA_CODE")"
else
	echo "内核校验: 跳过"
fi
echo "加载内核..."
sleep 0.5
bash kernel/system.sh
