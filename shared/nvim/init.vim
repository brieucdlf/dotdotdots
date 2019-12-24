let mapleader = ","

if !has('gui_running')
  set t_Co=256
endif

" Plugins
call plug#begin('~/.local/share/nvim/plugged')
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'

Plug 'mattn/emmet-vim'
Plug 'machakann/vim-highlightedyank'
Plug 'vimwiki/vimwiki'
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'plasticboy/vim-markdown'
Plug 'ap/vim-css-color'
Plug 'nelstrom/vim-markdown-folding'
Plug 'jiangmiao/auto-pairs'
Plug 'ntpeters/vim-better-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'junegunn/vim-easy-align'
Plug 'ryanoasis/vim-devicons'
Plug 'sheerun/vim-polyglot'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'leafgarland/typescript-vim'
Plug 'vim-syntastic/syntastic'

Plug 'arcticicestudio/nord-vim'
Plug 'itchyny/lightline.vim'
call plug#end()

"+--- itchyny/lightline.vim ---+
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [
      \     [ 'mode', 'paste' ],
      \     [ 'fugitive', 'filename' ]
      \   ]
      \ },
      \ 'component_function': {
      \   'fugitive': 'LightlineFugitive',
      \   'readonly': 'LightlineReadonly',
      \   'modified': 'LightlineModified',
      \   'filename': 'LightlineFilename'
      \ },
      \ 'separator': {
      \   'left': '',
      \   'right': ''
      \ },
      \ 'subseparator': {
      \   'left': '',
      \   'right': ''
      \ }
    \ }

function! LightlineModified()
  if &filetype == "help"
    return ""
  elseif &modified
    return "+"
  elseif &modifiable
    return ""
  else
    return ""
  endif
endfunction

function! LightlineReadonly()
  if &filetype == "help"
    return ""
  elseif &readonly
    return ""
  else
    return ""
  endif
endfunction

function! LightlineFugitive()
  if exists("*fugitive#head")
    let branch = fugitive#head()
    return branch !=# '' ? ' '.branch : ''
  endif
  return ''
endfunction

function! LightlineFilename()
  return ('' != LightlineReadonly() ? LightlineReadonly() . ' ' : '') .
       \ ('' != expand('%:t') ? expand('%:t') : '[No Name]') .
       \ ('' != LightlineModified() ? ' ' . LightlineModified() : '')
endfunction

" Vim gutter
let g:gitgutter_realtime = 1
let g:gitgutter_eager = 1

" Font
set gfn=Source\ Code\ Pro\ Regular\ 12

" Auto set currentdir
:set autochdir

" Shell
set shell=/bin/zsh

" mouse enable
set mouse=a

" Lightline : do not show mode under it
set noshowmode

" Macos clipboard sharing
set clipboard=unnamed


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

" [NerdTree]
nnoremap <leader>a :NERDTreeToggle<cr>

" [Searching]
nnoremap <leader><space> :nohlsearch<cr>
nnoremap / /\v
vnoremap / /\v
set ignorecase
set smartcase
set hlsearch
set incsearch

" [Git status]
nnoremap <leader>w :Gstatus<cr>

" [Editor]
set autoindent
set ruler
set scrolljump=-15
set backspace=indent,eol,start
set cursorline
set textwidth=100
set colorcolumn=100
set expandtab
set number
set foldcolumn=1
set foldenable
set foldlevelstart=10
set guicursor=a:ver25-Cursor/lCursor
set linebreak
set list
set listchars=eol:¬,space:·,tab:»\
set magic
set mat=2
set shiftwidth=2
set showmatch

" Toggle the sign column automatically when there are signs available to display.
set signcolumn=auto
set smartindent
set smarttab
set softtabstop=2
set tabstop=2
set textwidth=160

" Automatically wrap left and right.
" This allows to move the cursor to the previous/next line after reaching first/last character in the line using the arrow keys in normal-, insert- (<,>) and visual mode ([,]) or the h and l keys.
set whichwrap+=<,>,h,l,[,]
set wrap

" Shows syntax highlighting groups for the current cursor position
nmap <C-S-K> :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
