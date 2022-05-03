

CEDRIC_BRACKET_COLOR="%{$fg[white]%}"
CEDRIC_TIME_COLOR="%{$fg[247]%}"
CEDRIC_DIR_COLOR="%{$fg[yellow]%}"
CEDRIC_GOOD_COLOR="%{$fg[green]%}"
CEDRIC_BAD_COLOR="%{$fg[red]%}"

function cedric_git_prompt(){
  tmp=$(git rev-parse --git-dir 2> /dev/null)
  if [ $? -ne 0 ]; then
    #not a git folder
    return 
  fi
  GITSTATUS=$(git status --porcelain 2> /dev/null)
  GITBRANCH=$(git_current_branch)
  if [[ -n $GITSTATUS ]]; then
     echo "${CEDRIC_BAD_COLOR}{${GITBRANCH}} "
  else
     echo "${CEDRIC_GOOD_COLOR}(${GITBRANCH}) "
  fi
}

function cedric_root_prompt(){
    if [ "$USERNAME" = "root" ]; then
        echo " ${CEDRIC_BAD_COLOR}ROOT"
    fi

}

#allpyenvversions=$(source ~/.pyenvrc; pyenv versions)

function pyenv_virtualenv() {
#    currentversions=$(pyenv version | cut -d' ' -f1 | sed 's/\n/ /g')
#    echo
#    
#    
#    PYTHON_STR=""
#    while IFS= read -r python_version; do
#        tmp=$(echo $allpyenvversions | grep "/envs/$python_version")
#        if [[ $? -eq 0 ]]; then
#           if [[ "${PYTHON_STR}" == "" ]]; then
#               PYTHON_STR="(${python_version}"
#           else
#               PYTHON_STR="${PYTHON_STR},${python_version}"
#           fi
#    
#        fi
#    done <<< "$currentversions"
#    
#    if [[ "${PYTHON_STR}" != "" ]]; then
#        PYTHON_STR="${PYTHON_STR})"
#    fi
#    echo $PYTHON_STR
}

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX=""

ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""

# Our elements:
CEDRIC_TIME="${CEDRIC_TIME_COLOR}%D{%m.%d %H:%M:%S} %{$reset_color%}"
CEDRIC_DIR="${CEDRIC_DIR_COLOR}%~"
CEDRIC_PROMPT="${CEDRIC_BRACKET_COLOR}> "

# Put it all together!
PROMPT=$'\$(pyenv_virtualenv)${CEDRIC_TIME}%m \$(cedric_git_prompt)${CEDRIC_DIR}\$(cedric_root_prompt)${CEDRIC_PROMPT}%{$reset_color%}'

