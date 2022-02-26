" Make the default gVim Window larger.
set lines=50
set columns=132

" Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
set guioptions-=m
set guioptions-=L
set guioptions-=r
set guioptions-=t
set guioptions-=T

" Select a pretty font. :) Font size equals 12px on a 96 DPI display.
if has('gui_gtk')
  set guifont=Source\ Code\ Pro\ 9
  set guifont+=Monospace\ 9
endif

" This doesn't actually affect gVim itself; it sets $TERM inside :terminal
" windows. Otherwise, they default to "xterm", which doesn't support 256 colors.
let $TERM="xterm-256color"
