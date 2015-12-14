" Maintainer:   Simone Trubian <simone.trubian@gmail.com>
" Since:        Sun Feb 15 20:39:09 GMT 2015
" Description:  Neovim configuraton file based on personal .vimrc

" ------------------------------------------------------------------------- #
"           GENERAL
" ------------------------------------------------------------------------- #
" Avoid autosaving backups.
set nobackup
set nowritebackup
set noswapfile

set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set ignorecase          " Ignore character cases while searching.
set smartcase           " If a searched string contains an uppercase

set statusline=%F\ %m%r%h%w[%{&ff}]%y\ %p%%\ [%L]\ L:\ %04l,\ C:\ %03v

set lazyredraw          " Don't redraw while executing macros.
set splitbelow          " Open the new window below the current.
set splitright          " Open the new window to the right of the current.

" Manage buffer writing.
set noautowrite         " Don't write automatically when moving from a buffer.
set hidden
set bufhidden=hide      " Invisible buffers will be hid.

" Set wild menu parameters.
set wildmode=list:longest,full  " Set wild autocompletion params.
set wildignore=*.o,*~,*.pyc,*.swp

" Set number column.
set number              " Show row number.
set numberwidth=5       " Number column takes 5 columns.
set relativenumber      " Show relative row numbers from the currently used.
set cpoptions+=n        " Use number colum for the text of wrapped lines.

" Always highlight column 80 so it's easier to see where
" cutoff appears on longer screens
autocmd BufWinEnter * highlight ColorColumn ctermbg=blue
set colorcolumn=80

" Display special Characters and helpers
set list
" Show < or > when characters are not displayed on the left or right.
" Also show tabs and trailing spaces.
set list listchars=trail:¬,tab:>-,precedes:<,extends:>

set expandtab           " Automatically transform tabs in blank spaces.
set shiftwidth=4        " Set 4 spaces as default indentation.
set softtabstop=4       "

" ------------------------------------------------------------------------- #
"           MAPPINGS
" ------------------------------------------------------------------------- #

" Sync the unnamed register with the clipboard.
set clipboard^=unnamedplus

" Disable arrow keys.
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Move through buffers using arrows.
nmap <Left> :bp<CR>
nmap <Right> :bn<CR>

" Move through splits.
nmap <C-l> <C-W>l
nmap <C-h> <C-W>h
nmap <C-j> <C-W>j
nmap <C-k> <C-W>k

" Remove buffer without removing the split.
nmap <C-c> :bp\|bd #<CR>

" Toggle highligted searches.
nnoremap <C-t> :if (&hlsearch == 1) \| set nohlsearch \| else \| set hlsearch \| endif <cr>

" Paste timestamp.
imap <C-t> <ESC>:r!date<CR>kJA
