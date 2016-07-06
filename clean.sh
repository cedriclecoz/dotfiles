#!/bin/bash

echo "This script is going to remove the following symbolic links:"
echo " ~/.bashrc"
echo " ~/.vim"
echo " ~/.vimrc"
echo " ~/.inputrc"
echo " ~/.gitignore"
echo " ~/dotfiles"
echo " and the folder vim/vim/bundle"

echo "Terminal might be unstable following this removal."
read -n1 -r -p "Press a key to continue... Ctrl-C to cancel" key
listToRemove=" ~/.bashrc ~/.vim ~/.vimrc ~/.inputrc ~/dotfile/ "

for file in ${listToRemove}; do
    if [ -L ~/dotfiles ]; then
        echo ${file} is symbolic link, remove
    else
        echo ${file} is not symbolic link, skip
    fi
done

echo "remove vim/vim/bundle"
rm -rf vim/vim/bundle

