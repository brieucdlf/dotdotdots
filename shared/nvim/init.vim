let mapleader = ","

if !has('gui_running')
  set t_Co=256
endif

" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'

Plug 'machakann/vim-highlightedyank'
Plug 'vimwiki/vimwiki'
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'plasticboy/vim-markdown'
Plug 'nelstrom/vim-markdown-folding'
Plug 'jiangmiao/auto-pairs'
Plug 'ntpeters/vim-better-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'junegunn/vim-easy-align'
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'vim-syntastic/syntastic'

Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'arcticicestudio/nord-vim'
Plug 'itchyny/lightline.vim'
call plug#end()

" Auto set currentdir
:set autochdir

" Shell
set shell=/bin/zsh

" mouse enable
set mouse=a

" Highlight current line
set cursorline

" Lightline : do not show mode under it
set noshowmode

" Macos clipboard sharing
set clipboard=unnamed

" Deoplete
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Markdown
let g:markdown_fold_style = 'nested'
let g:vimwiki_global_ext=0
let g:vimwiki_table_mappings=0
let g:vimwiki_folding='expr'

" Highlighted yank
let g:highlightedyank_highlight_duration = 400

" ColorSheme
colorscheme nord
" let g:challenger_deep_termcolors=16

" better vertial movement for wrapped lines
nnoremap j gj
nnoremap k gk

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" [scrooloose/nerdcommenter]
" Don't be too smart across lines
let g:AutoPairsMultilineClose=0
" Don't insert extra spaces
let g:AutoPairsMapSpace=1

" Use arrow keys to switch tabs
nnoremap <Left> :tabprevious<CR>
nnoremap <Right> :tabnext<CR>

" quickly cancel search highlighting
nnoremap <leader><space> :nohlsearch<cr>

" Toggle NerdTree
nnoremap <leader>a :NERDTreeToggle<cr>

" FZF
if executable('fzf')
  " silent! nmap <C-p> :FZF<cr>
  silent! nmap <C-p> :GFiles<cr>
endif
" read/write file when switching buffers
set autowrite
set autoread

" Do case insensitive matching
set ignorecase

" Show matching brackets
set showmatch

" highlight search results
set hlsearch

" Searching
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase

" Git status
nnoremap <leader>w :Gstatus<cr>

" Display hidden characters
set list
set listchars=tab:▸\ ,eol:¬

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" Highlight the line the cursor is on.
set cursorline

" accelerated scrolling
set scrolljump=-15

" show the cursor position all the time
set ruler

" tab settings
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab
set smarttab

" Column limits
set textwidth=80
set colorcolumn=80

" line number
set number

" Don't use Ex mode, use Q for formatting
map Q gq

" Automatic indentation is good
set autoindent
