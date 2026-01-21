"""
" DO THE VUNDLE DANCE
"
"  ref: https://github.com/VundleVim/Vundle.vim
"
set nocompatible
filetype off

" TODO(zk): avoid hard-coding path to dotfiles repo
set rtp+=~/dotfiles/vim/bundle/Vundle.vim
call vundle#begin('~/dotfiles/vim/bundle')

Plugin 'VundleVim/Vundle.vim'

Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'
" for better list handling
Plugin 'bullets-vim/bullets.vim'

call vundle#end()
filetype indent plugin on

"
" VUNDLE DANCE CULMINATED
"""

set tabstop=4
set shiftwidth=4
set expandtab

set autoindent

colorscheme desert
syntax on
set number

nnoremap p p`]
nnoremap P P`]

autocmd BufNewFile,BufRead *.envrc set syntax=sh
autocmd BufNewFile,BufRead *.ipynb set syntax=json
autocmd BufNewFile,BufRead poetry.lock set syntax=toml

command! -nargs=1 -complete=command Stay call <SID>Stay(<f-args>)
function! s:Stay(cmd) range
  let view = winsaveview()
  execute a:cmd
  call winrestview(view)
endfunction

"""
" vim-markdown conf
"   ref: https://old.reddit.com/r/vim/comments/c2h28r/a_small_markdown_mapping_for_checkboxes/
"

" disable vim-markdown's bullet auto-insert in favour of the bullets plugin
let g:vim_markdown_auto_insert_bullets = 0

" no folds
let g:vim_markdown_folding_disabled = 1
" shrink toc if possible
let g:vim_markdown_toc_autofit = 1
" fancy syntax concealment
autocmd FileType markdown set conceallevel=2
" but not for code blocks
let g:vim_markdown_conceal_code_blocks = 0
" yaml frontmatter
let g:vim_markdown_frontmatter = 1
" open Toc
autocmd Filetype markdown nnoremap <silent> <localleader>j :Toch<cr>
" select from TOC and quit
autocmd FileType qf nnoremap <Space> <cr>:only<cr>

function Check()
    let l:line=getline('.')
    let l:curs=winsaveview()
    if l:line=~?'\s*-\s*\[\s*\].*'
        s/\[\s*\]/[.]/
    elseif l:line=~?'\s*-\s*\[\.\].*'
        s/\[.\]/[x]/
    elseif l:line=~?'\s*-\s*\[x\].*'
        s/\[x\]/[ ]/
    endif
    call winrestview(l:curs)
endfunction

autocmd FileType markdown nnoremap <buffer> <silent> - :Stay keeppatterns s/^\s*-\s*\[\zs.\ze\]/\=get({' ': 'X', 'X': ' '}, submatch(0), ' ')/e<cr>
