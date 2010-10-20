" This configuration is based on the example vimrc included with Arch Linux,
" the Vim Tips Wiki, and the vimrc file Ben Breedlove sent me to look at.
" (Thanks, Ben!)

" Enable Vim improvements at the expense of losing full vi compatibility.
set nocompatible

" Set display options.
set laststatus=2
set number
set numberwidth=5
set ruler
set showcmd
set linebreak

" Give us a big command history.
set history=999

" Make backspace act normally.
set backspace=indent,eol,start

" Make indentation behave in a civilized manner.
set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent

" Enable settings specific to various file formats.
filetype on
filetype plugin on
filetype indent on

let g:tex_flavor="latex"

" Configure the LaTeX Box plugin.
let g:LatexBox_latexmk_options="-pvc"

" If possible, tweak the indentation settings a bit for certain file formats.
if has("autocmd")
  autocmd FileType css        setlocal tabstop=4 shiftwidth=4
  autocmd FileType haskell    setlocal tabstop=4 shiftwidth=4
  autocmd FileType html       setlocal tabstop=4 shiftwidth=4
  autocmd FileType javascript setlocal tabstop=4 shiftwidth=4
  autocmd FileType php        setlocal tabstop=4 shiftwidth=4
  autocmd FileType python     setlocal tabstop=4 shiftwidth=4
  autocmd FileType sql        setlocal tabstop=4 shiftwidth=4
endif

" If possible, make indentation smarter.
if has("smartindent")
  set smartindent
endif

" If possible, enable fancy search settings.
if has("extra_search")
  set incsearch
  set hlsearch
endif

" If possible, enable mouse support.
if has("mouse")
  set mouse=a
endif

" If possible, enable syntax highlighting.
if has("syntax") && (&t_Co > 2 || has("gui_running"))
  syntax on
endif

" All the xterm-like terminals I use support 256 colors, so let's make Vim
" aware of that.
if &term == "xterm"
  set t_Co=256
endif

if has("gui_running")
  " Make the default gVim Window larger.
  set lines=50
  set columns=132

  " Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
  " See also: <http://vim.wikia.com/wiki/Hide_toolbar_or_menus_to_see_more_text>
  set guioptions-=t
  set guioptions-=T
  set guioptions-=r

  " Set a pretty font. :)
  " See also: <http://vim.wikia.com/wiki/Setting_the_font_in_the_GUI>.
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

  " If possible, enable spell checking. (Only do this for gVim as it's just
  " too ugly in the terminal.)
  if has("spell")
    set spell
    set spellfile=~/.vim/spellfile.add
  endif

  " Set a nice color scheme.
  colorscheme desert
elseif &t_Co == 88 || &t_Co == 256
  " Set a nice color scheme.
  colorscheme desert256-transparent
endif

" If possible, highlight trailing whitespace.
" See also: <http://vim.wikia.com/wiki/Highlight_unwanted_spaces>.
if has("autocmd") && has("syntax") && (&t_Co > 2 || has("gui_running"))
  highlight ExtraWhitespace ctermbg=red guibg=red
  autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
  autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
  autocmd InsertLeave * match ExtraWhitespace /\s\+$/
  autocmd BufWinLeave * call clearmatches()
endif
