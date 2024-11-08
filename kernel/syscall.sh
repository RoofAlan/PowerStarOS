#!/bin/bash


export pt_ver="PowerStarOS 0.2a"

PT_VER() {
	echo "$pt_ver Copyright (C)   2023-2024 Xigua"
}

SYS_OFF() {
	kill $(cat $exp/.pid_s)
	rm $exp/.pid_s
	exit
}
MEM_FREE() {
	free -k | awk '{print $4}' | head -n2 | tail -n1
}
SHOW_KLOG() {
	cat $exp/etc/kernel.log
}
export -f SHOW_KLOG
export -f MEM_FREE
export -f PT_VER
export -f SYS_OFF
