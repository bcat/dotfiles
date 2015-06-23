" Make the default gVim Window larger.
set lines=50
set columns=132

" Kill off the gVim toolbar and scrollbar, and fix the tear-off menus.
set guioptions-=m
set guioptions-=L
set guioptions-=r
set guioptions-=t
set guioptions-=T

" Set a pretty font. :) To make things a bit more cross-platform, we actually
" specify several fonts: a primary and a few fallbacks.
if has('gui_gtk2')
  set guifont=GohuFont\ 11px
  set guifont+=Envy\ Code\ R\ 10
  set guifont+=Consolas\ 10
  set guifont+=DejaVu\ Sans\ Mono\ 10
  set guifont+=Courier\ New\ 10
elseif has('gui_win32')
  set guifont=GohuFont:h8:cDEFAULT
  set guifont+=Envy_Code_R:h10:cDEFAULT
  set guifont+=Consolas:h10:cDEFAULT
  set guifont+=DejaVu_Sans_Mono:h10:cDEFAULT
  set guifont+=Courier_New:h10:cDEFAULT
endif
