#!/bin/bash

echo "This script is going to remove:"
echo " ~/.bashrc"
echo " ~/.vim"
echo " ~/.vimrc"
echo " ~/.inputrc"
echo " vim/vim/bundle"
if [ -L ~/dotfiles ]; then
    echo " ~/dotfiles"
fi
echo "Terminal might be unstable following this removal."
read -n1 -r -p "Press a key to continue... Ctrl-C to cancel" key

rm ~/.bashrc ~/.vim ~/.vimrc ~/.inputrc 
rm -rf vim/vim/bundle

if [ -L ~/dotfiles ]; then
    rm ~/dotfiles
fi


