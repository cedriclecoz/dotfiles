

CEDRIC_BRACKET_COLOR="%{$fg[white]%}"
CEDRIC_TIME_COLOR="%{$fg[yellow]%}"
CEDRIC_DIR_COLOR="%{$fg[cyan]%}"
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
     echo "${CEDRIC_BRACKET_COLOR}:${CEDRIC_BAD_COLOR}(${GITBRANCH})"
  else
     echo "${CEDRIC_BRACKET_COLOR}:${CEDRIC_GOOD_COLOR}(${GITBRANCH})"
  fi
}

function cedric_root_prompt(){
    if [ "$USERNAME" = "root" ]; then
        echo " ${CEDRIC_BAD_COLOR}ROOT"
    fi

}

# These Git variables are used by the oh-my-zsh git_prompt_info helper:
ZSH_THEME_GIT_PROMPT_PREFIX=""

ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""

# Our elements:
CEDRIC_TIME="${CEDRIC_BRACKET_COLOR}[${CEDRIC_TIME_COLOR}%D{%H:%M:%S}${CEDRIC_BRACKET_COLOR}] %{$reset_color%}"
CEDRIC_DIR="${CEDRIC_DIR_COLOR}%~"
CEDRIC_PROMPT="${CEDRIC_BRACKET_COLOR} ➭ "

# Put it all together!
PROMPT=$'\n${CEDRIC_TIME}${CEDRIC_DIR}\$(cedric_git_prompt)\$(cedric_root_prompt)${CEDRIC_PROMPT}%{$reset_color%}'

