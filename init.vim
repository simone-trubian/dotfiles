" Use spacebar as leader and ; as secondary-leader
let g:mapleader="\<Space>"
let g:maplocalleader=';'

set nobackup            " Do not keep a backup file, use versions instead.
set nowritebackup
set noswapfile

set history=50          " keep 50 lines of command line history
set ruler               " show the cursor position all the time
set showcmd             " display incomplete commands
set incsearch           " do incremental searching
set ignorecase          " Ignore character cases while searching.
set smartcase           " If a searched string contains an uppercase

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
