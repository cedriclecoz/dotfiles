#!/bin/bash

rm ~/.bashrc ~/.vim ~/.vimrc ~/.inputrc 
rm -rf vim/vim/bundle

if [ -L ~/dotfiles ]; then
    rm ~/dotfiles
fi


