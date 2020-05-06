
macstr="Darwin"

alias a="alias "

if [ "$(uname)" == "$macstr" ]; then
    a ls='ls -G'
else
    a ls='ls -G --color=auto'
fi
a l='ls -la'
a lp='ls -lart'
a p='cd ..'
a md='mkdir -p'
a sapti="sudo apt-get install "
a gvim='UBUNTU_MENUPROXY= gvim'
a k='~/dotfiles/scripts/k.sh'
a rst='/usr/bin/reset && source ~/.bash_aliases'
a givm='gvim '
a xls='open -a "Microsoft Excel" '
a doc='open -a "Microsoft Word" '

# Kill all running containers.
a dockerkillall='docker kill $(docker ps -q)'

# Delete all stopped containers.
a dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images.
a dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images.
a dockerclean='dockercleanc || true && dockercleani'

function mktags {
    ~/.bash_scripts/mktags.sh $@&
}

tmux_bin=
if [ "$(uname)" == "$macstr" ]; then
    tmux_bin="/usr/local/bin/tmux"
else
    tmux_bin="/usr/bin/tmux"
    echo "not Mac.. Linux."
fi

function tmux {

    if [ "$#" == "0" ]; then
        idx=`${tmux_bin} ls 2> /dev/null | grep windows | wc -l | tr -d '[[:space:]]'`
        session_name="tmux_${idx}" 
        ${tmux_bin} new -s ${session_name}
    else
        ${tmux_bin} $@
    fi
}

function rma {
    if [ "$#" = "0" ]; then
        echo "file(s) to rm need to be given....."
    else
        rmdate="rm-ed_$( date '+%Y-%m-%d_%H-%M-%S' )"
            echo "mv '$*' to ~/AVIRER/$rmdate"
            if ! [ -e  ~/AVIRER ]; then
                mkdir ~/AVIRER
            fi
            mkdir ~/AVIRER/$rmdate
            mv $* ~/AVIRER/$rmdate
    fi

}

function goto_head {
    oldpwd=$PWD
    while [ ! -d ".git" -a "$PWD" != "/" ]; do
        cd ..
    done
    if [ "$PWD" = "/" ]; then
        cd $oldpwd
    fi
}

function mk {
	unset PERL_MM_OPT; goto_head; make $* ; alert
}

a mx='mk xconfig'

function gr {
	if [ $# -ge 2 ]; then
	     	grep  -r -n --color=always --exclude-dir=".svn" --exclude-dir=".vimtags" $@; 
	else 
	     	grep  -r -n --color=always --exclude-dir=".svn" --exclude-dir=".vimtags"  $1 .;
	fi; 
}
function gri {
	if [ $# -ge 2 ]; then 
		grep  -ri -n --color=always --exclude-dir=".svn" --exclude-dir=".vimtags" $@; 
	else
		grep  -ri -n --color=always --exclude-dir=".svn" --exclude-dir=".vimtags"  $1 .; 
	fi; 
}

function vig {
   vi_file=`echo "$1" | gawk -F : '{print $1}'`;
   vi_line=`echo "$1" | gawk -F : '{print $2}'`;
   vi $vi_file +$vi_line;
}
function gvig {
   vi_file=`echo "$1" | gawk -F : '{print $1}'`;
   vi_line=`echo "$1" | gawk -F : '{print $2}'`;
   gvim $vi_file +$vi_line;
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

function sshdel {
    echo "Delete entries $1 from ~/.ssh/known_hosts"
    sed -i '' "/${1}/d" ~/.ssh/known_hosts
    valid_ip $1
    if [ $? != 0 ]; then
      ipadd=$(ping -c 1 -t 1 build-yocto-persistent-alanr | grep PING | sed 's/.*(//' | sed 's/).*//')
      echo "Removing ip address $ipadd"
      sed -i '' "/${ipadd}/d" ~/.ssh/known_hosts
    fi
}

# ------------------
# git----------
# ------------------

# ( these will me moved to the git config)
alias gl='git pull '
alias gh='git push'
alias glom='git pull origin master '
alias ghom='git push origin master'
alias gd='git difftool --tool=gvimdiff'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
#alias gb='git branch'
alias gs='git status'
alias gsb='git status -sb'
alias gss='git status -s' # short, waffle-free
#alias gs='git status -u no' # untracked not listed ...??? misses mods!
# my py equivalence tool - requires git config setup of course
alias gequ='git difftool -t pyequiv'
# Git-aware prompt (overwrites PS1 of course)
# ( Note - this doesn't auto refresh of course; will only change on a new prompt(
#  Customize BASH PS1 prompt to show current GIT repository and branch.
#  by Mike Stewart - http://MediaDoneRight.com

#  SETUP CONSTANTS
#  Bunch-o-predefined colors.  Makes reading code easier than escape sequences.
#  I don't remember where I found this.  o_O

# Reset
Color_Off="\[\033[0m\]"       # Text Reset

# Regular Colors
Black="\[\033[0;30m\]"        # Black
Red="\[\033[0;31m\]"          # Red
Green="\[\033[0;32m\]"        # Green
Yellow="\[\033[0;33m\]"       # Yellow
Blue="\[\033[0;34m\]"         # Blue
Purple="\[\033[0;35m\]"       # Purple
Cyan="\[\033[0;36m\]"         # Cyan
White="\[\033[0;37m\]"        # White

# Bold
BBlack="\[\033[1;30m\]"       # Black
BRed="\[\033[1;31m\]"         # Red
BGreen="\[\033[1;32m\]"       # Green
BYellow="\[\033[1;33m\]"      # Yellow
BBlue="\[\033[1;34m\]"        # Blue
BPurple="\[\033[1;35m\]"      # Purple
BCyan="\[\033[1;36m\]"        # Cyan
BWhite="\[\033[1;37m\]"       # White

# Underline
UBlack="\[\033[4;30m\]"       # Black
URed="\[\033[4;31m\]"         # Red
UGreen="\[\033[4;32m\]"       # Green
UYellow="\[\033[4;33m\]"      # Yellow
UBlue="\[\033[4;34m\]"        # Blue
UPurple="\[\033[4;35m\]"      # Purple
UCyan="\[\033[4;36m\]"        # Cyan
UWhite="\[\033[4;37m\]"       # White

# Background
On_Black="\[\033[40m\]"       # Black
On_Red="\[\033[41m\]"         # Red
On_Green="\[\033[42m\]"       # Green
On_Yellow="\[\033[43m\]"      # Yellow
On_Blue="\[\033[44m\]"        # Blue
On_Purple="\[\033[45m\]"      # Purple
On_Cyan="\[\033[46m\]"        # Cyan
On_White="\[\033[47m\]"       # White

# High Intensty
IBlack="\[\033[0;90m\]"       # Black
IRed="\[\033[0;91m\]"         # Red
IGreen="\[\033[0;92m\]"       # Green
IYellow="\[\033[0;93m\]"      # Yellow
IBlue="\[\033[0;94m\]"        # Blue
IPurple="\[\033[0;95m\]"      # Purple
ICyan="\[\033[0;96m\]"        # Cyan
IWhite="\[\033[0;97m\]"       # White

# Bold High Intensty
BIBlack="\[\033[1;90m\]"      # Black
BIRed="\[\033[1;91m\]"        # Red
BIGreen="\[\033[1;92m\]"      # Green
BIYellow="\[\033[1;93m\]"     # Yellow
BIBlue="\[\033[1;94m\]"       # Blue
BIPurple="\[\033[1;95m\]"     # Purple
BICyan="\[\033[1;96m\]"       # Cyan
BIWhite="\[\033[1;97m\]"      # White

# High Intensty backgrounds
On_IBlack="\[\033[0;100m\]"   # Black
On_IRed="\[\033[0;101m\]"     # Red
On_IGreen="\[\033[0;102m\]"   # Green
On_IYellow="\[\033[0;103m\]"  # Yellow
On_IBlue="\[\033[0;104m\]"    # Blue
On_IPurple="\[\033[10;95m\]"  # Purple
On_ICyan="\[\033[0;106m\]"    # Cyan
On_IWhite="\[\033[0;107m\]"   # White


# Various variables you might want for your PS1 prompt instead
Time12h="\T"
Time12a="\@"
PathShort="\W"
PathFull="\w"
NewLine="\n"
Jobs="\j"
Date='\D{%m.%d}'
Uname="\u"
Hostname="\h"

if [ "$(uname)" == "$macstr" ]; then
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash
    source /Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=true
fi

# untracked files present
export PS1=$IBlack$Date" "$Time12h" "$Hostname$Color_Off'$(git branch &>/dev/null;\
if [ $? -eq 0 ]; then \
  echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; \
  if [ "$?" -eq "0" ]; then \
    # @4 - Clean repository - nothing to commit
    if [ "`whoami`" == "root" ]; then \
        echo "'$Red' ROOT'$Green'"$(__git_ps1 " (%s)"); \
    else \
        echo " '$Green'"$(__git_ps1 " (%s)"); \
    fi; \
  else \
    # @5 - Changes to working tree
    if [ "`whoami`" == "root" ]; then \
        echo "'$Red' ROOT'$IRed'"$(__git_ps1 " {%s}"); \
    else \
        echo " '$IRed'"$(__git_ps1 " {%s}"); \
    fi;\
  fi) '$BYellow$PathFull$Color_Off'> "; \
else \
  # @2 - Prompt when not in GIT repo
  if [ "`whoami`" == "root" ]; then \
    echo "'$Red' ROOT '$Yellow$PathFull$Color_Off'> "; \
  else \
    echo " '$Yellow$PathFull$Color_Off'> "; \
  fi;\
fi)'

# project_aliases
if [ -e ~/.project_aliases ]; then
    source ~/.project_aliases
fi

