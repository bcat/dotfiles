" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

" Enable Vim improvements at the expense of losing full vi compatibility.
set nocompatible

" Give us a big command history.
set history=999

" Make backspace act normally.
set backspace=indent,eol,start

" Make indentation behave in a civilized manner.
set tabstop=2
set shiftwidth=2
set expandtab

set autoindent
set smartindent
set smarttab

filetype plugin indent on
autocmd FileType css        setlocal tabstop=4 shiftwidth=4
autocmd FileType haskell    setlocal tabstop=4 shiftwidth=4
autocmd FileType html       setlocal tabstop=4 shiftwidth=4
autocmd FileType javascript setlocal tabstop=4 shiftwidth=4
autocmd FileType php        setlocal tabstop=4 shiftwidth=4
autocmd FileType python     setlocal tabstop=4 shiftwidth=4

" Set display options.
set ruler
set number
set numberwidth=5
set showcmd
set incsearch
set laststatus=2

" All the xterm-like terminals I use support 256 colors, so let's make Vim
" aware of that.
if &term == "xterm"
  set t_Co=256
endif

" If possible, enable syntax highlighting and other pretty things.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" If possible, set up a nice color scheme and font.
if has("gui_running")
  colorscheme desert

  if has("gui_gtk2")
    set guifont=Envy\ Code\ R\ 10
  elseif has("gui_photon")
    set guifont=Envy\ Code\ R\ s:10
  elseif has("gui_kde")
    set guifont=Envy\ Code\ R/10/-1/5/50/0/0/0/1/0
  elseif has("x11")
    set guifont=-*-Envy\ Code\ R-medium-r-normal-*-*-180-*-*-m-*-*
  else
    set guifont=Envy_Code_R:h10:cDEFAULT
  endif
elseif &t_Co == 88 || &t_Co == 256
  colorscheme desert256-transparent
endif
