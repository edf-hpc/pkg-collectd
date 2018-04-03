#!/bin/bash

# This script is a collectd plugin that gathers metrics
# from nVidia cards.

declare -A config=(
#	["temperature_gpu"]=temperature
#	["fan_speed"]=percent
#	["pstate"]=absolute
#	["memory_used"]=memory
#	["memory_free"]=memory
	["utilization_gpu"]=percent
	["utilization_memory"]=percent
#	["power_draw"]=power
)

HOSTNAME="${COLLECTD_HOSTNAME:-$(hostname --fqdn)}"                              
INTERVAL="${COLLECTD_INTERVAL:-10}"         

for parameter in "${!config[@]}"
do
	query_string="${parameter//_/.},"
	gpus_state=$(nvidia-smi --query-gpu="${query_string}" --format=csv,noheader,nounits)
	
	i=0
	while read line
	do
		i=$((i+$line))
	done <<< "${gpus_state// }"
	
	echo "PUTVAL ${HOSTNAME}/cuda/${config[$parameter]}-${parameter} interval=$INTERVAL N:$i"
done
