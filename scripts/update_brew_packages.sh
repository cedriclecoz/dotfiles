#!/bin/bash

if [ $(which brew) ]; then
    STAMPFILE="${HOME}/.brewupdatedate"
    
    # Time to update brew?
    oldDate=$(cat ${STAMPFILE} 2>/dev/null||echo 0)
    currDate=$(date +%s)
    if [ ${currDate} -gt $((${oldDate}+86399)) ]; then
        screen -ls | grep brewupdategrade
        if [ $? != 0 ]; then
            echo "starting brew update upgrade in screen brewupdategrade"
            screen -dmSL brewupdategrade bash -c 'echo ""; echo ""; date; brew update; brew upgrade'
            echo ${currDate} > ${STAMPFILE}
        else
            echo "A screen brewupdategrade is alreaddy in progress.. skip."
        fi
    fi
else
    exit 
fi

