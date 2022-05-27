let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
"Plug 'vim-scripts/taglist.vim'
Plug 'https://github.com/majutsushi/tagbar'
Plug 'fholgado/minibufexpl.vim'
Plug 'chrisbra/Colorizer'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'vim-scripts/multisearch.vim'
Plug 'rodjek/vim-puppet'

call plug#end()

