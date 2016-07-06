#!/bin/bash

# run pylint on changed files (default) or an explict list
# for now it will exit on the first failure
# The checks should be exactly the same as run on the git hooks
# so it is important when changes are made that the two checkers
# are kept in sync

# ----------------------------------------------------------------------
# helper methods
# ----------------------------------------------------------------------

# functions shared with the git hook
# (include in your bin folder as well )
. lint_settings.sh



function is_python_file () {

    local result
    filename=$(basename $1)
    extension="${filename##*.}"
    if [ "$extension" == "py" ]; then
        result=1
    else
        result=0
    fi
    echo $result
}
function run_lint () {
    local settings
    echo 'checking: ' $1
    if [ $2 -eq 1 ]; then 
        pylint $(get_pylint_settings) $1
    else 
        pylint $(get_pylint_settings) $1 > /dev/null
    fi
    if [ $? -eq 0 ]; then
        echo -e '\t> OK'
    else
        echo -e '\t> FAIL!'
    fi

}
function finish {
  echo 'finished'
}
trap finish EXIT



# ----------------------------------------------------------------------
# script execution enters here
# ----------------------------------------------------------------------

# list input
#files_to_check=''
#echo "files to check:" $files_to_check    "Hello"
verbose=0
echo " Warning - run is invalid (BUG) if not invoked from the project root"
while [[ $# > 0 ]]
do
    if [ "$1" == "-v" ]; then
        verbose=1
    else
        files_to_check+=' '$1
    fi
    shift
done

# or run on the git changed set
if [ -z "$files_to_check" ]; then
    echo "using git to check for changes"
    files_to_check=$(git diff --name-only)
    if [ $? -eq 0 ]; then
        echo 'looking for changed python files'
        #echo $files_to_check
    else
        # this shouldn't happen
        echo 'unexpected fail to diff the commits (sha invalid?) - exiting'
        exit 1
    fi
fi

for file in $files_to_check
do
    if [ $(is_python_file $file) -eq 1 ]; then

        run_lint $file $verbose
    fi
done

# got here so everything ok
exit 0


