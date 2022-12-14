#!/bin/bash
TYPE=$1
PARAM=$2
echo -e "Pid\tMemory\t\tName"
# 格式化内存
function memory_format {
  size=$1
  unit="Kb"
  if [ $size -ge 1048576 ]; then
    size=`echo "scale=2; ${size}/1024" | bc`
    unit="Gb"
  elif [ $size -ge 1024 ]; then
    size=`echo "scale=2; ${size}/1024" | bc`
    unit="Mb"
  fi
  str="$size $unit"
  if [ ${#str} -lt 8 ]; then
    str+='\t'
  fi
  echo "$str"
}
if [ "$1" == 'service' ]; then
  service_names=`systemctl | grep $PARAM | awk -F '.service ' '{print $1}' | grep -oP [^\ ]+$`
  for name in $service_names
  do
    service_status=`systemctl status $name`
    if [ -n "`echo "$service_status" | grep -o 'Active: active (running)'`" ]; then
      pid=`echo "$service_status" | grep -oP "Main PID:\\s+\\d+" | grep -oP "\\d+"`
      memory=$(memory_format $(cat /proc/$pid/status | grep VmRSS | grep -oP "\\d+"))
      echo -e "$pid\t$memory\t$name"
    fi
  done
elif [ "$1" == 'ps' ]; then
  ps -aux | grep $PARAM | while read name
  do
    pid=`echo "$name" | awk -F ' ' '{print $2}'`
    memory=$(memory_format $(echo "$name" | awk -F ' ' '{print $6}'))
    name=`echo "$name" | tr -s ' ' | cut -d ' ' -f 11-`
    echo -e "$pid\t$memory\t$name"
  done
fi