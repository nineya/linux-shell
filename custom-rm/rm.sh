#!/bin/bash
HOME=/backup
VERSION=1.2
if [ -z "$USER" ]; then
  USER="unknown"
fi
STORE_HOME=$HOME/$USER/$(date +%Y%m%d/%H%M%S)
function error_print {
  echo -e "\033[31;7mError:\033[0;31m $1\033[0m" 1>&2
  exit 1
}

function create_dir {
  new_path=$1
  i=1
  while [ -e "$new_path" ]
  do
    new_path=$1-$i
    let i++
  done
  echo $new_path
}
function print_help {
  echo -e "\033[36mCustom RM commands \033[33m$VERSION\033[0m"
  echo -e "All deleted files will be moved to the Recycle Bin: \033[33m$HOME\033[0m"
  mv --help
  exit 0
}
if [ 0 == $# ]; then
  print_help
fi

for s in $*;
do
  if [ "$s" == "--help" ]; then
    print_help
  elif [ ${s:0:2} == "--" ]; then
    error_print "Long parameters are not currently supported"
  elif [ ${s:0:1} == "-" ]; then
    param=$param`echo $s | sed -r "s/[^bfinStTuvZ]+//g"`
  fi
done
if [ -n "$param" ]; then
  param=" -"$param
fi
if [ -f "$STORE_HOME" ]; then
  error_print "Cannot create directory because file with same name exists"
fi
declare -A pathMap
for s in $*;
do
  if [ "${s:0-1}" == "*" ]; then
    path=${s%/*}
    if [ ! -d "$path" ] || [ -z "$(ls -A $path)" ]; then
      continue
    fi
    path=$(cd $path; pwd)
    new_path=${pathMap[$path]}
    if [ -z $new_path ]; then
      new_path=$(create_dir $STORE_HOME$path)
      mkdir -p ${new_path}
      pathMap[$path]=$new_path
    fi
    for file in `ls $path`
    do
      mv$param $file $new_path
    done
  elif [ -d "$s" ]; then
    path=$(cd $s; pwd)
    path=${path%/*}'/'
    new_path=${pathMap[$path]}
    if [ -z $new_path ]; then
      new_path=$(create_dir $STORE_HOME$path)
      mkdir -p $new_path
      pathMap[$path]=$new_path
    fi
    mv$param $s $new_path
  elif [ -e "$s" ]; then
    path=$(cd `dirname $s`; pwd)
    new_path=${pathMap[$path]}
    if [ -z $new_path ]; then
      new_path=$(create_dir $STORE_HOME$path)
      mkdir -p $new_path
      pathMap[$path]=$new_path
    fi
    mv$param $s $new_path
  fi
done
