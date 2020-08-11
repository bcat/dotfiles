" Make the default gVim Window larger.
set lines=50
set columns=132

" Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
set guioptions-=m
set guioptions-=L
set guioptions-=r
set guioptions-=t
set guioptions-=T

" Select a pretty font. :) To make things a bit more cross-platform, we actually
" specify several fonts: a primary and a few fallbacks. Font sizes are chosen to
" give 12px fonts on 96 DPI Linux/Windows displays and 72 DPI OS X displays.
if has('gui_gtk')
  set guifont=Source\ Code\ Pro\ 9
  set guifont+=Inconsolata\ 9
  set guifont+=Monospace\ 9
elseif has('gui_win32')
  set guifont=Source_Code_Pro:h9:cDEFAULT
  set guifont+=Consolas:h9:cDEFAULT
  set guifont+=Courier_New:h9:cDEFAULT
elseif has('gui_macvim')
  set guifont=Source\ Code\ Pro:h12
  set guifont+=Menlo:h12
  set guifont+=Monaco:h12
endif

" This doesn't actually affect gVim itself; it sets $TERM inside :terminal
" windows. Otherwise, they default to "xterm", which doesn't support 256 colors.
let $TERM="xterm-256color"
