#!/bin/bash

CUR_FOLDER=$(pwd)

macstr="Darwin"
linuxstr="Linux"
ret=

cat .git/config | grep -i "/dotfiles" > /dev/null
if [ "$?" != "0" ]; then
    echo "Please launch $0 from the dotfile git folder root"
    exit -1
fi

echo "WARNING deploy script will:"
echo " - create the following symbolic links in ${HOME}  (existing links won't be overwritten):"
echo "    dotfiles"
echo "    .bashrc"
echo "    .vim"
echo "    .vimrc"
echo "    .inputrc"
if [ "$(uname)" == "$macstr" ]; then
    echo " - install brew if not already installed"
    echo " - install up-to-date bash if current version is 3.* (brew version)"
    echo " - install gvim if not already installed (brew version)"
    echo " - install iTerm2 if not already installed (brew version)"
    echo " - install ctags if not already installed (brew version)"
    echo " - launch locate service"
else
    echo
    echo " - WARNING - created for MAC OS, need to add the apt-get install for linux"
    echo
fi


read -n1 -r -p "Press a key to continue..." key


if [ "$(uname)" == "${macstr}" ]; then
#    if [ $(which brew) ]; then
#        ret="${ret}\nbrew already installed, ignore"
#    else
#        echo "install brew"
#        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
#    fi
#
#    if [ $(which git) ]; then
#        ret="${ret}\ngit already installed, ignore"
#    else
#        echo "install git"
#        brew install git
#    fi
#    tmp=$(bash --version | grep 'version 3\.')
#    if [ "$tmp" == "" ]; then
#        ret="${ret}\nbash at version $(bash --version), ignore"
#    else
#        echo "install bash (brew version)"
#        brew install bash
#        ret="${ret}\n!!!! bash installed, version: $(bash --version)"
#    fi
    if [ -e /usr/local/bin/ctags ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install ctags"
        brew install ctags
    fi
#    if [ ! -e /Applications/iTerm.app ]; then
#        echo "install iTerm2"
#        brew install Caskroom/cask/iterm2
#    else
#        ret="${ret}\niTerm2 already exist, ignore"
#    fi
#    if [ $(which tmux) ]; then
#        ret="${ret}\ngit already installed, ignore"
#    else
#        echo "install tmux"
#        brew install tmux
#    fi
#     if [ ! -e /usr/local/bin/reattach-to-user-namespace ]; then
#        ret="${ret}\reattach-to-user-namespace already installed, ignore"
#    else
#        echo "install reattach-to-user-namespace"
#        brew install reattach-to-user-namespace
#    fi
    if [ $(which gvim) ]; then
        ret="${ret}\nmacvim(gvim) already installed, ignore"
    else
        echo "install macvim"
        brew install macvim
    fi
#    if [ -e /Applications/Karabiner.app ]; then
#        ret="${ret}\nkarabiner already installed, ignore"
#    else
#        echo "install karabiner"
#        brew install Caskroom/cask/karabiner
#    fi
fi
if [ "$(uname)" == "${linuxstr}" ]; then

    if [ $(which git) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install git"
        sudo apt-get install -y git
    fi
    tmp=$(bash --version | grep 'version 3\.')
    if [ "$tmp" == "" ]; then
        ret="${ret}\nbash at version $(bash --version), ignore"
    else
        echo "do something for bash ?"
    fi
    if [ -e /usr/local/bin/ctags ]; then
        ret="${ret}\nctags already installed, ignore"
    else
        echo "do something for ctags ?"
        sudo apt-get install exuberant-ctags
        if [ -e /usr/bin/ctags ]; then
            sudo ln -s /usr/bin/ctags /usr/local/bin/ctags
        fi
    fi
    if [ $(which tmux) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install tmux"
        sudo apt-get install -y tmux
    fi
    if [ $(which gvim) ]; then
        ret="${ret}\ngvim already installed, ignore"
    else
        echo "install vim"
        sudo apt-get install -y vim-gnome
    fi

    sed -i.bak s/"set -g default-command"/"#set -g default-command"/g tmux.conf

    echo 'Installing build essentials and other packages.'
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils
fi


if [ ! -e ~/dotfiles ]; then
    echo "Current folder not in ${HOME}, create symbolic link"
    ln -sf ${CUR_FOLDER} ~/dotfiles
else
    ret="${ret}\n~/dotfiles already exist, ignore"
fi
if [ ! -e ~/.bashrc ]; then
    echo 'deploy bashrc'
    ln -sf ${CUR_FOLDER}/rcfiles/bashrc ~/.bashrc
else
    ret="${ret}\n~/.bashrc already exist, ignore"
fi
if [ ! -e ~/.zshrc ]; then
    echo 'deploy zshrc'
    ln -sf ${CUR_FOLDER}/rcfiles/zshrc ~/.zshrc
else
    ret="${ret}\n~/.zshrc already exist, ignore"
fi
if [ ! -e ~/.vim ]; then
    echo 'deploy vim/'
    mkdir -p ${CUR_FOLDER}/vim/vim
    ln -sf ${CUR_FOLDER}/vim/vim/ ~/.vim
else
    ret="${ret}\n~/.vim already exist, ignore"
fi
if [ ! -e ~/.vimrc ]; then
    echo 'deploy vimrc'
    ln -sf ${CUR_FOLDER}/vim/vimrc ~/.vimrc
else
    ret="${ret}\n~/.vimrc already exist, ignore"
fi
if [ ! -e ~/.inputrc ]; then
    echo 'deploy inputrc'
    ln -sf ${CUR_FOLDER}/rcfiles/inputrc ~/.inputrc
else
    ret="${ret}\n~/.inputrc already exist, ignore"
fi
if [ ! -e ~/.gitignore ]; then
    echo 'deploy gitignore'
    ln -sf ${CUR_FOLDER}/gitignore ~/.gitignore
else
    ret="${ret}\n~/.gitignore already exist, ignore"
    ret="${ret}\n    maybe check if ./gitignore and ~/.gitignore can be merged, and a symbolic link created"
fi


if [ ! -e pyenv ]; then
    echo "clone pyenv"
    git clone https://github.com/yyuu/pyenv.git pyenv
    ln -sf ${CUR_FOLDER}/pyenv ~/.pyenv
else
    ret="${ret}\npyenv already present, ignore"
fi

if [ ! -e rbenv ]; then
    echo "clone rbenv"
    git clone https://github.com/rbenv/rbenv.git
    ln -sf ${CUR_FOLDER}/rbenv ~/.rbenv
fi

if [ "$(uname)" == "$macstr" ]; then
    cmd="sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
    echo "Start locate service (need sudo)."
    echo "    ${cmd}"
    ${cmd}
fi

#see http://caiustheory.com/git-git-git-git-git/
#ignore multiple git :)
git config --global alias.git '!exec git'

rm -f ~/.brewupdatedate

printf "$ret\n"
