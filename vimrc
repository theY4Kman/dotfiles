set tabstop=4
set shiftwidth=4
set expandtab

filetype indent plugin on
set autoindent

autocmd BufNewFile,BufRead *.envrc set syntax=sh
autocmd BufNewFile,BufRead *.ipynb set syntax=json
autocmd BufNewFile,BufRead poetry.lock set syntax=toml

colorscheme desert
syntax on
set number
