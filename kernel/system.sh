#!/bin/bash
clear
sleep 1

CONFIG_FILE="kernel/kernel.conf"
read_config() {
        local section="$1" 
        local key="$2"
        # 使用grep查找指定的section和key，然后使用awk提取值
        local value=$(grep "^$key" "$CONFIG_FILE" | awk -F "=" '{print $2}')
        echo "$value"
}
[ ! -f "$CONFIG_FILE" ] && echo "Kernel init: error to load config" && exit 1
debug=$(read_config KERNEL debug)
[ "$debug" = "on" ] && echo "Debug is on"
echo "clean: etc/kernel.log"
echo -n "" > etc/kernel.log
[ "$debug" = "on" ] && echo "Load watchdog..."
start_ts=$(date +%s.%N)
painc() {
	local n_ts=$(echo "$(date +%s.%N) - $start_ts" | bc)
	if [ ! -z "$(echo $n_ts | awk -F'.' '{print $1}')" ]; then
		[ "$debug" = "on" ] && echo "[   $n_ts] $*"
		echo "[   $n_ts] $*" >> etc/kernel.log
	else
		[ "$debug" = "on" ] && echo "[   0$n_ts] $*"
		echo "[   0$n_ts] $*" >> etc/kernel.log
	fi
}
perr() {
	[ "$debug" = "on" ] && echo "[----$*----]"
	bash kernel/bosd.sh
	exit 1
}

painc "Watchdog load finish"
painc "Load syscall..."
[ -f "kernel/syscall.sh" ] && source "kernel/syscall.sh"
[ ! $? -eq 0 ] && perr "Error to load syscall"
painc $(PT_VER)
painc "Check file"

if [ ! -f "kernel/shell.sh" ]; then
       	perr "File 'shell.sh' does not exist"
else
	painc "File 'shell.sh' exsit"
fi

if [ ! -f "kernel/fs.sh" ]; then
	perr "File 'fs.sh' does not exist"
else
	painc "File 'fs.sh' exsit"
fi
painc "Memory free: $(MEM_FREE) K"
painc "Starting file check..."
bash kernel/fs.sh
[ ! $? -eq 0 ] && perr "File check failed"
painc "Loading shell..."
bash kernel/shell.sh
painc "The system will going down NOW!"
sleep 1
exit
