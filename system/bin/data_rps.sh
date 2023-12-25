#!/system/bin/sh

LOG_TAG="data_rps.sh"
rfc=4096
cc=4
cpumask=f;
function mlog()
{
	echo "$@"
	log -p d -t "$LOG_TAG" "$@"
}

function exe_log()
{
	mlog "$@";
	eval $@;
}

function rps_on()
{
	chipType=$(getprop ro.board.platform)
	chipType2=$(getprop ro.product.model)
	if [ "$chipType" = "sp9850ka" ]; then
		##add read option for java to read
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/dynamic_load_disable"
		##set the all cpu core online
		exe_log "echo 1 >/sys/devices/system/cpu/cpuhotplug/dynamic_load_disable";
	elif [ "$chipType" = "sp9853i" ]; then
		##add read option for java to read
		#exe_log "chmod o+r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
		##set the all cpu core online
		exe_log "echo userspace >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu1/online"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu2/online"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu3/online"
	elif [ "$chipType" = "sc9850kh" ]; then
		exe_log "echo 0 > /sys/devices/system/cpu/cpuhotplug/qos_core_ctl"
		exe_log "echo userspace >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu0/online"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu1/online"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu2/online"
		exe_log "echo 1 > /sys/devices/system/cpu/cpu3/online"
		exe_log "echo 0 > /sys/class/thermal/thermal_zone0/thm_enable"
	elif [ "$chipType2" = "SP9832A" ]; then
		mlog "CHIP:$chipType2 valid chipType,support."
		##add read option for java to read
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		##set the all cpu core online
		exe_log "echo 1 >/sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable";
		retVal=$(cat /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable)
		mlog "the current cpuhotplug status is $retVal."
	elif [ "$chipType2" = "SC9820W" ]; then
		mlog "CHIP:$chipType2 valid chipType,support."
		cpumask=3;
		cc=2;
		##add read option for java to read
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		##set the all cpu core online
		exe_log "echo 1 > /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		retVal=$(cat /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable)
		mlog "the current cpuhotplug status is $retVal."
	else
		mlog "CHIP:$chipType or $chipType2 is invalid chipType, not support."
		exit 1
	fi
	sleep 1;
	##Enable RPS (Receive Packet Steering)
	((rsfe=$cc*$rfc));
	echo "$rsfe";
	exe_log "echo $rsfe > /proc/sys/net/core/rps_sock_flow_entries"
	retVal=$(cat /proc/sys/net/core/rps_sock_flow_entries)
	mlog "the flow entries value is $retVal"
	for fileRps in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_cpus)
		do
			exe_log "echo $cpumask > $fileRps";
			retVal=$(cat $fileRps)
			mlog "the value of $fileRps is $retVal"
		done
	for fileRfc in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_flow_cnt)
		do
			exe_log "echo $rfc > $fileRfc";
			retVal=$(cat $fileRfc)
			mlog "the value of $fileRfc is $retVal"
		done
}

function rps_off()
{
	chipType=$(getprop ro.board.platform)
	chipType2=$(getprop ro.product.model)
	if [ "$chipType" = "sp9850ka" ]; then
		##add read option for java to read
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/dynamic_load_disable"
		##close the all cpu core online
		exe_log "echo 0 >/sys/devices/system/cpu/cpuhotplug/dynamic_load_disable";
	elif [ "$chipType" = "sp9853i" ]; then
		##add read option for java to read
		#exe_log "chmod o+r /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
		exe_log "echo interactive >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
	elif [ "$chipType" = "sc9850kh" ]; then
		exe_log "echo 1 > /sys/devices/system/cpu/cpuhotplug/qos_core_ctl"
		exe_log "echo interactive >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"
		exe_log "echo 1 > /sys/class/thermal/thermal_zone0/thm_enable"
	elif [ "$chipType2" = "SP9832A" ]; then
		##add read option for java to read
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		##close the all cpu core online
		exe_log "echo 0 > /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable";
	elif [ "$chipType2" = "SC9820W" ]; then
		exe_log "chmod o+r /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		##close the all cpu core online
		exe_log "echo 0 > /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable"
		retVal=$(cat /sys/devices/system/cpu/cpuhotplug/cpu_hotplug_disable)
		mlog "the current cpuhotplug status is $retVal"
	fi
	exe_log "echo 0 > /proc/sys/net/core/rps_sock_flow_entries"
	retVal=$(cat /proc/sys/net/core/rps_sock_flow_entries)
	mlog "the sock flow entries value is $retVal"
	for fileRps in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_cpus)
		do
			exe_log "echo 0 > $fileRps";
			retVal=$(cat $fileRps)
			mlog "the value of $fileRps is $retVal"
		done
	for fileRfc in $(ls /sys/class/net/seth_lte*/queues/rx-*/rps_flow_cnt)
		do
			exe_log "echo 0 > $fileRfc";
			retVal=$(cat $fileRfc)
			mlog "the value of $fileRfc is $retVal"
		done
}

if [ "$1" = "on" ]; then
	rps_on;
elif [ "$1" = "off" ]; then
	rps_off;
fi
