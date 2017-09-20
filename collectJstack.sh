#!/bin/bash

JOB_ID=201709200523_0026

# Jstack for attempt is controlled by "lightPollingInterval" and jstack for JT and TT is controlled by "heavyPollingInterval" .  Both the values are set in seconds.

lightPollingInterval=1 # every second
heavyPollingInterval=5 # every 5 second

jtJstack=1   #Set this to "0" to disable jstack collection for JobTracker
ttJstack=1   #Set this to "0" to disable jstack collection for TaskTracker
taskJstack=1 #Set this to "0" to disable jstack collection for task attempts

JT_DIR=/tmp/jstack/jt
TT_DIR=/tmp/jstack/tt
mkdir -m 777 -p ${JT_DIR}
mkdir -m 777 -p ${TT_DIR}

if [ `ps -ef | grep -w "collectJstack.sh daemon" | grep -v -w -e grep | tr -s '  ' ' ' | cut -f 2-3 -d " " | grep -v -w -e $$ | wc -l` -ne 0 ]; then
  echo ERROR: This script is already running!
  ps -ef | grep -w "collectJstack.sh daemon" | grep -v -w -e grep
  exit 1
fi

if [ "n$1" = "ndaemon" ]; then

nextLightPolling=0
nextHeavyPolling=0
while true; do 
	now=`date +%s`
  	if [ $now -ge $nextLightPolling ]; then
		nextLightPolling=$(( $now + $lightPollingInterval ))
		if [ $taskJstack -eq 1 ]; then
		FULL_DATE=$(date +%Y%m%d%H%M)
		FOLDER=/tmp/jstack/${FULL_DATE}
		mkdir -m 777 -p ${FOLDER} 
		for TASK_PID in $(ps -ef |grep ${JOB_ID} |grep java | grep attempt| awk '{print $2}')
		do ATTEMPT=$(ps -ef |grep -w ${TASK_PID} |sed -n 's#.*\(attempt.*\)/work.*#\1#p')
		jstack ${TASK_PID} > ${FOLDER}/${ATTEMPT}-${TASK_PID}-$(date +%Y%m%d%H%M%S).jstack
	     	done
		fi
	fi

	if [ $now -ge $nextHeavyPolling ]; then
    		nextHeavyPolling=$(( $now + $heavyPollingInterval ))
		if [ $jtJstack -eq 1 ]; then
		jstack $(ps -ef | grep '[h]adoop.log.file=hadoop-mapr-tasktracker' | grep -v attempt | awk '{print $2}') > ${JT_DIR}/jobtracker-$(date +%Y%m%d%H%M%S).jstack
		fi
	
		if [ $ttJstack -eq 1 ]; then
                jstack $(ps -ef | grep '[h]adoop.log.file=hadoop-mapr-jobtracker' | grep -v attempt | awk '{print $2}') > ${TT_DIR}/tasktracker-$(date +%Y%m%d%H%M%S).jstack
		fi

	fi
sleep 1
done
else 
  echo Launching collection daemon
  nohup $0 daemon < /dev/null > /tmp/collectJstack.$HOSTNAME.out 2>&1 &
fi
