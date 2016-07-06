#!/bin/bash

if [ "$#" == "0" ]; then
    echo "Usage:  $1 folder1ToParse folder2ToParse ..."
    echo "If Full tree: $1 ."
fi

list_ko=''
for folder in $*; do
    listPython=`find $folder -name "*.py"`
    for filePython in $listPython; do
        tmp=`lint_changed.sh $filePython | grep FAIL`
        if [ "$tmp" != "" ]; then
            list_ko="$list_ko $filePython"
        fi
    done
done

echo $list_ko
for file in $list_ko; do
    lint_changed.sh -v $file
done
for file in $list_ko; do
    echo "please correct the file $file"
done

echo ""

if [ "$list_ko" != "" ]; then
    echo "$list_ko"
fi
