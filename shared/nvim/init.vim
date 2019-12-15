let mapleader = ","

if !has('gui_running')
  set t_Co=256
endif

" Plugins
call plug#begin('~/.local/share/nvim/plugged')

Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
Plug 'plasticboy/vim-markdown'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'ntpeters/vim-better-whitespace'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'terryma/vim-multiple-cursors'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-sensible'

Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'arcticicestudio/nord-vim'

Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'sheerun/vim-polyglot'

" Language Protocol Server and autocompelete
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'
Plug 'ncm2/ncm2-vim-lsp'

call plug#end()

" set Vim-specific sequences for RGB colors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
 if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
 endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
   set termguicolors
  endif
endif

colorscheme nord
" let g:challenger_deep_termcolors=16

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" macOS clipboard sharing
set clipboard=unnamed

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

" LSP and autocomplete
" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()
set completeopt=noinsert,menuone,noselect
" When the <Enter> key is pressed while the popup menu is visible, it only
" hides the menu. Use this mapping to close the menu and also start a new
" line.
inoremap <expr> <CR> (pumvisible() ? "\<c-y>\<cr>" : "\<CR>")
" suppress the annoying 'match x of y', 'The only match' and 'Pattern not
" found' messages
set shortmess+=cI
nnoremap <leader>e :LspHover<cr>
nnoremap <leader>d :LspDefinition<cr>

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
