set exrc

call plug#begin('~/.vim/plugged')

" Coc plugins
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Fzf Plugins
Plug 'junegunn/fzf', {'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'

" Debugger Plugins
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

" Tpope because the best
Plug 'tpope/vim-fugitive'
Plug 'preservim/nerdcommenter'

" telescope requirements...
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" UI
Plug 'vim-airline/vim-airline'
Plug 'arcticicestudio/nord-vim'

call plug#end()

filetype plugin on
if has('termguicolors')
  set termguicolors
endif
let loaded_matchparen = 1
let mapleader = " "

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" greatest remap ever
vnoremap <leader>p
nnoremap <C-p> :FZF<CR>

" next greatest remap ever : asbjornHaland
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG

command! -nargs=0 Prettier :CocCommand prettier.formatFile

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
