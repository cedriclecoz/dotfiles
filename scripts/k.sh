#!/bin/bash 
shname=`echo "$0" | awk -F'/' '{print $NF}'`

PTypeList="Z T"

Opt=

COLOR_SUCCESS="\e[0;32m"
COLOR_FAILURE="\e[0;31m"
COLOR_RST='\e[0m'

if [ $# -gt 1 -o "$1" == "-h" -o "$1" == "help" ]; then
   echo "--------------------------------------------------------------------------------"
   echo "Usage : $shname [options]"
   echo "   options"
   echo "            Killing '$PTypeList' child processes of current terminal"
   echo "      -a    Killing all '$PTypeList' system processes associated with a terminal"
   echo "--------------------------------------------------------------------------------"
   exit 1
fi

if [ "$1" == "-a" ]; then
   echo "Killing all '$PTypeList' system processes associated with a terminal..."
   Opt=$1
else
   echo "Killing '$PTypeList' child processes of current terminal..."
fi



pidToKill=
for PType in $PTypeList; do
    tmp=`ps $Opt -o pid,state | grep $PType | grep -v PID | awk -F' ' '{print $1}'`
    pidToKill="$pidToKill $tmp"
done

for pid in $pidToKill; do
    process=`ps ax | grep "$pid" | grep -v "grep $pid"| sed "s/  */ /g"| cut -d" " -f5-`
    kill -9 $pid
#    tmp=`ps ax | grep "$pid" | grep -v "grep $pid"`
#    if [ "$tmp" = "" ]; then
    if [ $? -ne 0 ]; then
        echo -e "killing '$process'...  ${COLOR_FAILURE}[KO]${COLOR_RST}"
    else
        echo -e "killing '$process'...  ${COLOR_SUCCESS}[OK]${COLOR_RST}"
    fi
done


echo "Done."
