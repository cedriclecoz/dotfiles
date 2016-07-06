#!/bin/bash

CUR_FOLDER=$(pwd)
macstr="Darwin"
ret=
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
fi


read -n1 -r -p "Press a key to continue..." key


if [ "$(uname)" == "$macstr" ]; then
    if [ $(which brew) ]; then
        ret="${ret}\nbrew already installed, ignore"
    else
        echo "install brew"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi
    
    if [ $(which git) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install git"
        brew install git
    fi
    tmp=$(bash --version | grep 'version 3\.')
    if [ "$tmp" == "" ]; then
        ret="${ret}\nbash at version $(bash --version), ignore"
    else
        echo "install bash (brew version)"
        brew install bash
        ret="${ret}\n!!!! bash installed, version: $(bash --version)"
    fi
    if [ -e /usr/local/bin/ctags ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install ctags"
        brew install ctags
    fi
    if [ ! -e /Applications/iTerm.app ]; then
        echo "install iTerm2"
        brew install Caskroom/cask/iterm2
    else
        ret="${ret}\niTerm2 already exist, ignore"
    fi
    if [ $(which tmux) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install tmux"
        brew install tmux
    fi
     if [ ! -e /usr/local/bin/reattach-to-user-namespace ]; then
        ret="${ret}\reattach-to-user-namespace already installed, ignore"
    else
        echo "install reattach-to-user-namespace"
        brew install reattach-to-user-namespace
    fi   
    if [ $(which gvim) ]; then
        ret="${ret}\nmacvim(gvim) already installed, ignore"
    else
        echo "install macvim"
        brew install macvim
    fi
    if [ -e /Applications/Karabiner.app ]; then
        ret="${ret}\nkarabiner already installed, ignore"
    else
        echo "install karabiner"
        brew install Caskroom/cask/karabiner
    fi
fi
if [ ! -e ~/dotfiles ]; then
    echo "Current folder not in ${HOME}, create symbolic link"
    ln -sf ${CUR_FOLDER} ~/dotfiles
else
    ret="${ret}\n~/dotfiles already exist, ignore"
fi
if [ ! -e ~/.bashrc ]; then
    echo 'deploy bashrc'
    ln -sf ${CUR_FOLDER}/bashrc ~/.bashrc
else
    ret="${ret}\n~/.bashrc already exist, ignore"
fi
if [ ! -e ~/.vim ]; then
    echo 'deploy vim/'
    ln -sf ${CUR_FOLDER}/vim/vim ~/.vim
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
    ln -sf ${CUR_FOLDER}/inputrc ~/.inputrc
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

mkdir -p ${CUR_FOLDER}/vim/vim/bundle
if [ ! -e ${CUR_FOLDER}/vim/vim/bundle/neobundle.vim ]; then
    echo "clone neobundle.vim"
    git clone git://github.com/Shougo/neobundle.vim.git ${CUR_FOLDER}/vim/vim/bundle/neobundle.vim
else
    ret="${ret}\nneobundle.vim already exist, ignore"
fi

if [ ! -e pyenv ]; then
    echo "clone pyenv"
    git clone https://github.com/yyuu/pyenv.git pyenv
    ln -sf ${CUR_FOLDER}/pyenv ~/.pyenv
else
    ret="${ret}\npyenv already present, ignore"
fi

if [ "$(uname)" == "$macstr" ]; then
    cmd="sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
    echo "Start locate service (need sudo)."
    echo "    ${cmd}"
    ${cmd}
fi

printf "$ret\n"
