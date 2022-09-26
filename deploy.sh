#!/bin/bash

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR
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
echo "    .zshrc"
echo "    .vim"
echo "    .vimrc"
echo "    .inputrc"
if [ "$(uname)" == "$macstr" ]; then
    if [ "$(uname -m)" != "x86_64" ]; then
        echo " - install rosetta (to allow running intel compiled apps)"
    fi
    echo " - install brew if not already installed"
    echo " - install up-to-date bash if current version is 3.* (brew version)"
    echo " - install gvim if not already installed (brew version)"
    echo "        => This is my custom gvim setup, it installs plugins and some keys F1:F9 are predefined to do some actions, see vim/vimrc"
    echo " - install iTerm2 if not already installed (brew version)"
    echo "         => Terminal, https://iterm2.com"
    echo " - install rectangle if not already installed (brew version)"
    echo "         => Windows management, https://rectangleapp.com"
    echo " - install aws cli v2 if not already installed"
    echo "         => Aws cli, https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    echo " - install pyenv"
    echo "         => Python management, https://github.com/pyenv/pyenv"
    echo " - install pyenv virtualenv"
    echo "         => Python management, https://github.com/pyenv/pyenv-virtualenv"
    echo " - install pyenv python"
    echo " - install rbenv"
    echo "         => Ruby management, https://github.com/rbenv/rbenv"
    echo " - install npm"

    echo " - install ctags if not already installed (brew version)"
    echo " - launch locate service"
else
    echo
    echo " - WARNING - created for MAC OS, need to add the apt-get install for linux"
    echo
fi


read -n1 -r -p "Press a key to continue..." key

mkdir -p ~/.historylogs

if [ "$(uname)" == "${macstr}" ]; then
    if [ "$(uname -m)" != "x86_64" ] && [ ! -f ~/.rosetta_installed ]; then
        softwareupdate --install-rosetta
        touch ~/.rosetta_installed
    fi
    if [ $(which brew) ]; then
        ret="${ret}\nbrew already installed, ignore"
    else
        echo "install brew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ "$(uname -m)" != "x86_64" ]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.bash_profile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/Homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
            echo 'eval "$(/usr/local/Homebrew/brew shellenv)"' >> ${HOME}/.bash_profile
            eval "$(/usr/local/Homebrew/bin/brew shellenv)"
        fi
    fi

    if [ $(which git) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install git"
        brew install git
    fi
    if [ $(which wget) ]; then
        ret="${ret}\nwget already installed, ignore"
    else
        echo "install wget"
        brew install wget
    fi
    tmp=$(bash --version | grep 'version 3\.' || :)
    if [ "$tmp" == "" ]; then
        ret="${ret}\nbash at version $(bash --version | head -n1), ignore"
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
    if [ ! -e /Applications/Rectangle.app ]; then
        echo "install rectangle"
        brew install --cask rectangle
    else
        ret="${ret}\nRectangle already exist, ignore"
    fi

    if [ $(which tmux) ]; then
        ret="${ret}\ngit already installed, ignore"
    else
        echo "install tmux"
        brew install tmux
    fi
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
    
    if [ $(which aws) ]; then
        ret="${ret}\naws already installed, ignore"
    else
        echo "install aws"
        wget https://awscli.amazonaws.com/AWSCLIV2.pkg -O /tmp/awscliv2.pkg
        sudo installer -pkg /tmp/awscliv2.pkg -target /
    fi

    if [ $(which npm) ]; then
        ret="${ret}\nnpm already installed, ignore"
    else
        echo "install npm"
        brew install npm
    fi
    if [ $(which aws-azure-login) ]; then
        ret="${ret}\aws-azure-login already installed, ignore"
    else
        echo "install aws-azure-login"
        npm install -g aws-azure-login
    fi

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
    #if [ -e /usr/local/bin/ctags ]; then
    #    ret="${ret}\nctags already installed, ignore"
    #else
    #    echo "do something for ctags ?"
    #    sudo apt-get install exuberant-ctags
    #    if [ -e /usr/bin/ctags ]; then
    #        sudo ln -s /usr/bin/ctags /usr/local/bin/ctags
    #    fi
    #fi
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


if [ ! -d ~/.oh-my-zsh ]; then
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /tmp/ohmyzsh_install.sh
    sh /tmp/ohmyzsh_install.sh --unattended
    ln -s ${HOME}/dotfiles/omzsh/themes/cedric.zsh-theme ${HOME}/.oh-my-zsh/themes/cedric.zsh-theme
else
    ret="${ret}\noh-my-zsh already installed, ignore"
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
    ret="${ret}\n    maybe check if $(pwd)/gitignore and ~/.gitignore can be merged, and a symbolic link created"
fi
if [ ! -e ~/.pyenvrc ]; then
    echo 'deploy pyenvrc'
    ln -sf ${CUR_FOLDER}/rcfiles/pyenvrc ~/.pyenvrc
else
    ret="${ret}\n~/.pyenvrc already exist, ignore"
fi

if [ ! -e pyenv ]; then
    echo "clone pyenv"
    git clone https://github.com/pyenv/pyenv.git pyenv
    ln -sf ${CUR_FOLDER}/pyenv ~/.pyenv
else
    ret="${ret}\npyenv already present, ignore"
fi
if [ ! -e pyenv/plugins/pyenv-virtualenv ]; then
    echo "clone pyenv-virtualenv"
    git clone https://github.com/pyenv/pyenv-virtualenv.git pyenv/plugins/pyenv-virtualenv
else
    ret="${ret}\npyenv/plugins/virtualenv already present, ignore"
fi

if [ ! -d pyenv/versions ] || [ "$(ls pyenv/versions/ | wc -l |tr -d '[:space:]')" == "0" ]; then
    echo "Install a pyenv python"
    source ~/.pyenvrc
    pyenv install -l
    read -p "Please enter version to install (will take a few min, press enter to skip): " PYENV_PROMPT
    if [ -z $PYENV_PROMPT ]; then
        echo "do not install a python version"
        ret="${ret}\nSkip installation of a pyenv python"
    else
        echo "Installing ${PYENV_PROMPT}"
        pyenv install ${PYENV_PROMPT}
    fi
else
    ret="${ret}\na python already present in ~/.pyenv/versions/, ignore"
    
fi

if [ ! -d rbenv ]; then
    echo "clone rbenv"
    git clone https://github.com/rbenv/rbenv.git
    ln -sf ${CUR_FOLDER}/rbenv ~/.rbenv
else
    ret="${ret}\nrbenv already present, ignore"
fi
if [ ! -d rbenv/plugins/ruby-build ]; then
    echo "clone rbenv"
    git clone https://github.com/rbenv/rbenv.git rbenv/plugins/ruby-build
else
    ret="${ret}\nrbenv/plugins/ruby-build already present, ignore"
fi





if [ "$(uname)" == "$macstr" ] && [ ! -f /tmp/locate_launched ]; then
    cmd="sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist"
    echo "Start locate service (need sudo)."
    echo "    ${cmd}"
    ${cmd}
    touch /tmp/locate_launched
fi

#see http://caiustheory.com/git-git-git-git-git/
#ignore multiple git :)
git config --global alias.git '!exec git'

rm -f ~/.brewupdatedate


printf "$ret\n"
echo ""
echo ""
echo "WARNING,  current deployement is using  my oh-my-zsh template, ${HOME}/.oh-my-zsh/themes/cedric.zsh-theme."
echo "it invokes the git plugin, which creates lots of aliases for git"
echo "see: https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/git/git.plugin.zsh"

echo "you might want to check if ~/.zshrc points correctly to the ~/dotfiles/rcfiles/zshrc and if not redo it, else if you are here, All Good!"

