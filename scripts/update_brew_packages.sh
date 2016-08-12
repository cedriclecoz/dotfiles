#!/bin/bash

STAMPFILE="${HOME}/.brewupdatedate"

# Time to update brew?
oldDate=$(cat ${STAMPFILE} 2>/dev/null||echo 0)
currDate=$(date +%s)
if [ ${currDate} -gt $((${oldDate}+86399)) ]; then
    if [ "$(brew update | grep 'No changes to formulae.')" != "" ]; then
        echo "Changes in some formulaes, upgrade"
        brew upgrade
    fi
    echo ${currDate} > ${STAMPFILE}
fi

