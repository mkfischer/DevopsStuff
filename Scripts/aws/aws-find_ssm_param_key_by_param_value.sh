#!/bin/bash
# Supply a value to find and a list containing SSM params to run on.
# A possible way to compile such a list is to run:
# aws ssm describe-parameters | jq -r ".Parameters[].Name" > all_params
# Script by Itai Ganot 2019

function usage(){
  echo "Usage: ${basedir}${0} -p parameter_value_to_find -l parameter_list"
  echo "Optional:        "
  echo "-d       [debug] "
}

if [[ $# -lt 4 ]]; then
  usage
  exit
fi

debug=false

while getopts ":p:l:d" opt; do
  case ${opt} in
    p)
      value_to_find=${OPTARG}
      ;;
    l)
      param_list=${OPTARG}
      ;;
    d)
      debug=true
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2;
      usage
      exit 1
      ;;
  esac
done

GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
NOCOLOR=$(tput sgr0)
cwd=$(pwd)
date_time=$(date +'%d-%m-%Y_%T' | tr ":" "-")
log=${cwd}/${value_to_find}-${date_time}.log
counter="0"
pid=$$

touch ${log}
echo "Pid: ${pid}"

for param in $(cat ${param_list}); do
  check_key=$(aws ssm get-parameters --with-decryption --names "${param}" | jq -r ".Parameters[] | .Value")
  if [[ ${check_key} = ${value_to_find} ]]; then
    echo "Value ${value_to_find} found in parameter ${param}" | tee -a ${log}
  fi
  if ${debug}; then
    counter=$(expr ${counter} + 1)
    echo -e "#${counter}: Finished processing {${CYAN}Key${NOCOLOR}:${param},${GREEN}Value${NOCOLOR}:${check_key}}"
  fi
done
echo -e "${GREEN} Finished working on value ${value_to_find}"
