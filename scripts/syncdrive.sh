#!/bin/bash

print_usage(){
    echo Usage: $0 fileName
}

ABS_NAME=
PASSPHRASE=ggdriveEncriptionCedric4237#!k

get_abs_fileName() {
    # generate absolute path from relative path
    # $1     : relative fileName
    # return : absolute path
    if [ -d "$1" ]; then
        # dir
        ABS_NAME=`echo $(cd "$1"; pwd)`
    elif [ -f "$1" ]; then
        # file
        if [[ $1 == */* ]]; then
            ABS_NAME=`echo "$(cd "${1%/*}"; pwd)/${1##*/}"`
        else
            ABS_NAME=`echo "$(pwd)/$1"`
        fi
    fi
}

if [ $# == 1 ]; then
    if [ ! -e $1 ]; then
        print_usage
        exit -1
    fi
    tmp_basename=`basename $1`
    tmp=`mktemp -d`

    tar czf $tmp/$tmp_basename.tgz $1
    ls $tmp
    echo "gpg -c --passphrase ${PASSPHRASE}  $tmp/$tmp_basename.tgz"
    gpg -c --batch --passphrase ${PASSPHRASE}  $tmp/$tmp_basename.tgz
    gdrive-osx-x64 upload --delete $tmp/$tmp_basename.tgz.gpg
    rm $tmp/$tmp_basename.tgz*
fi
if [ $# == 0 ]; then
#    tmp=`drive-linux-x64 download --pop`
    tmp=`gdrive-osx-x64 list --order "recency desc" | grep -v Created | awk -F' ' '{print $1}'`
    idx=''
    fileName=''
    for idx in $tmp; do
        fileName=`gdrive-osx-x64 info $idx | grep 'Name:' | awk -F' ' '{print $2}'`
        echo "$idx - $fileName"
        gdrive-osx-x64 download --delete $idx
        break
    done
    if [ "${fileName}" != "" ]; then 

        gpg --batch --passphrase ${PASSPHRASE} ${fileName}
        ungpgFileName=`echo ${fileName} | awk -F'.gpg' '{print $1}'`
        tar xzf $ungpgFileName
        rm $fileName ${ungpgFileName}
    fi

fi




