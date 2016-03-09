" Maintainer:   Simone Trubian <simone.trubian@gmail.com>
" Since:        Sun Feb 15 20:39:09 GMT 2015
" Description:  Based on the example shipped with Vim74

" :scriptnames  Shows the list of sourcing directories.
" :set runtimepath+=/directory/name
" q:            Access to dynamic history list.
" ^]            Go to hyperlink in help files.
" :help index   Show all in-built key bindings.
" :xmap         Show all custom key bindings for that mode.
" %             In command mode expand the name of the file.
" %:p           In command mode expand filename with full path.
" %:p:h         Expand full path to file without the file name.
" gx            Opens a uri in the default web browser.
" 0             In Ex mode refers to the start of the file.
" zt            Shift the page so the cursor is at the top of the window.
" zb            Shift the page so the cursor is at the bottom of the window.
" :reg          Show content of all registers.
" :Explore      Explore the filesystem with vim.
" :jumps        List last 100 position changing commands entered, g; g,
" :changes      List last XX changes occurred, move with ^i, ^o


" Gvim
" :set clipborard+=unnamed      All text in the unnamed register is also
                                " replicated in the drop/selection registers.

" When started as 'evim', evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" ------------------------------------------------------------------------- #
"           PLUGINS
" ------------------------------------------------------------------------- #
" Load the pathogen plugin.
execute pathogen#infect()

" Use patched fonts with vim and gvim.
let g:airline_powerline_fonts = 1

" Avoid bufferline to echo onto the command bar
let g:bufferline_echo = 0
let g:airline_section_c = '%t'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#tabline#fnamemod = ':p:t'

" Enable branches exentions
let g:airline#extensions#branch#enabled = 1

" Enable virtualenv integration
let g:airline#extensions#virtualenv#enabled = 1


" --------- Flake8 -----------
let g:PyFlakeOnWrite = 1
let g:PyFlakeCheckers = 'pep8,mccabe,frosted'
let g:PyFlakeDefaultComplexity=10

" ------------------------------------------------------------------------- #
"           GENERAL
" ------------------------------------------------------------------------- #
" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set nobackup            " Do not keep a backup file, use versions instead.
set nowritebackup
set noswapfile

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set ignorecase          " Ignore character cases while searching.
set smartcase           " If a searched string contains an uppercase

" Statusline
set laststatus=2        " Always show the status line.

" Superseeded by Airline.
"set statusline=%F\ %m%r%h%w[%{&ff}]%y\ %p%%\ [%L]\ L:\ %04l,\ C:\ %03v

set autoread            " Read automatically a file if changed externally.
set lazyredraw          " Don't redraw while executing macros.
set splitbelow          " Open the new window below the current.
set splitright          " Open the new window to the right of the current.

" Error handling
set noerrorbells        " Silence the error bell.
set novisualbell        " Don't flash the screen when ar error occurs.
set t_vb=

" Manage buffer writing.
set noautowrite         " Don't write automatically when moving from a buffer.
set hidden
set bufhidden=hide      " Invisible buffers will be hid.

" Set wild menu parameters.
set wildmenu            " Set WiLd command mode.
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

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
  set mousehide         " Hide mouse when typing.
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax enable
  set hlsearch          " Highlight matching search patterns.
  set background=dark
  set t_Co=16
  colorscheme solarized " Add personal color scheme.
  let g:solarized_termcolors=16
endif

set expandtab           " Automatically transform tabs in blank spaces.
set shiftwidth=2        " XX
set softtabstop=2       " XX

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent                " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

" ------------------------------------------------------------------------- #
"           MAPPINGS
" ------------------------------------------------------------------------- #
" Sync the unnamed register with the clipboard.
set clipboard=unnamed

" Disable arrow keys.
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>
noremap   <C-m>  <NOP>

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

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

" Toggle highligted vertical cutoff.
nnoremap <C-m> :if (&colorcolumn == 80) \| set colorcolumn=0 \| else \| set colorcolumn=80 \| endif<cr>

" Toggle nerd tree.
nnoremap <C-n> :NERDTreeToggle<cr>
" Toggle highligted searches.
nnoremap <C-t> :if (&hlsearch == 1) \| set nohlsearch \| else \| set hlsearch \| endif <cr>

" Paste timestamp.
imap <C-t> <ESC>:r!date<CR>kJA
