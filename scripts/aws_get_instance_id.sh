#!/usr/bin/env bash
instance_name=${1}
if [ "$1" != "" ]; then
    profile="default"
    if [ "$2" != "" ]; then
       cat ~/.aws/credentials | grep "\[$2\]" 2>&1 > /dev/null
       if [ $? -ne 0 ]; then
           echo "profile $2 not in ~/.aws/credentials.... abort.." 
           return -1
       fi  
       profile="$2"
    fi
    instance_id=$(aws --profile ${profile} ec2 describe-instances --filter "Name=tag:Name,Values=${instance_name}" --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" --output text)
    echo ${instance_id}
fi

