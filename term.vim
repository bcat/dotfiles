" Vim uses the system terminfo for most configuration, augmented with some
" extensions from its builtin XTerm termcap when vim_is_xterm returns true.
"
" After that, Vim asynchronously parses v:termresponse for terminals where t_RV
" is defined, selectively enabling/disabling features based on this Secondary DA
" response. We extend this logic a bit ourselves.
function! s:TermResponse()
  " Vim silently clears the 8u termcap extension when it receives a Secondary DA
  " response from terminals it doesn't know support underline colors [1]. We
  " need to reset 8u to its proper value for terminals *we* know support it.
  "
  " [1]: https://github.com/vim/vim/blob/5c52be40fbab14e050d7494d85be9039f07f7f8f/src/term.c#L4805-L4809
  if &term =~# '\v^%(hterm|tmux)%($|-)'
    " SGR (Character Attributes): Set underline color, RGB
    "   CSI 58 ; 2 ; ; Pr ; Pg ; Pb m
    let &t_8u = "\e[58;2;%lu;%lu;%lum"
  endif
endfunction

if has('autocmd')
  augroup term_vim
    autocmd!
    autocmd TermResponse * call s:TermResponse()
  augroup END
end

" When vim_is_xterm [1] returns false, Vim's builtin XTerm termcap [2] isn't
" applied, and so several Vim-specific termcap extensions are undefined. For
" terminals we know behave like XTerm, we manually set these values.
"
" It would be nice if we reuse Vim's builtin termcap ourselves, but that isn't
" currently supported as of Vim 8.2 [3]. See the XTerm Control Sequences
" document [4] for the canonical reference on these sequences.
"
" [1]: https://github.com/vim/vim/blob/5c52be40fbab14e050d7494d85be9039f07f7f8f/src/os_unix.c#L2362-L2378
" [2]: https://github.com/vim/vim/blob/5c52be40fbab14e050d7494d85be9039f07f7f8f/src/term.c#L815-L1007
" [3]: https://github.com/vim/vim/issues/6609
" [4]: https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
if &term =~# '\v^%(hterm|tmux)%($|-)'
  " DECSCUSR (Set Cursor Style)
  "   CSI Ps SP q
  let &t_SH = "\e[%p1%d q"

  " Send Device Attributes (Secondary DA): Request terminal identification
  "   CSI > c
  let &t_RV = "\e[>c"

  " SGR (Character Attributes): Set foreground color, RGB
  "   CSI 38 ; 2 ; Pr ; Pg ; Pb m
  let &t_8f = "\e[38;2;%lu;%lu;%lum"

  " SGR (Character Attributes): Set foreground color, RGB
  "   CSI 48 ; 2 ; Pr ; Pg ; Pb m
  let &t_8b = "\e[48;2;%lu;%lu;%lum"

  " DECSET (DEC Private Mode Set): Bracketed paste mode
  "   CSI ? 2 0 0 4 h
  let &t_BE = "\e[?2004h"

  " DECRST (DEC Private Mode Reset): Bracketed paste mode
  "   CSI ? 2 0 0 4 l
  let &t_BD = "\e[?2004l"

  " XTWINOPS (Save Title): Window title
  "   CSI 2 2 ; 2 t
  let &t_ST = "\e[22;2t"

  " XTWINOPS (Restore Title): Window title
  "   CSI 2 3 ; 2 t
  let &t_RT = "\e[23;2t"

  " DECSET (DEC Private Mode Set): Focus tracking
  "   CSI ? 1 0 0 4 h
  let &t_fe = "\e[?1004h"

  " DECRST (DEC Private Mode Reset): Focus tracking
  "   CSI ? 1 0 0 4 l
  let &t_fd = "\e[?1004l"

  " Start of bracketed paste
  "   ESC [ 2 0 0 ~
  let &t_PS = "\e[200~"

  " End of bracketed paste
  "   ESC [ 2 0 1 ~
  let &t_PE = "\e[201~"

  " FocusIn event
  "   ESC [ I
  execute "set <FocusGained>=\e[I"

  " FocusOut event
  "   ESC [ O
  execute "set <FocusLost>=\e[O"
endif

" If the terminal supports it, set the cursor to a blinking bar in insert mode
" and a blinking underline in replace mode. (This matches the default behavior
" of the gVim cursor.)
if &term =~# '\v^%(hterm|tmux|xterm)%($|-)'
  " Set cursor to blinking bar when entering insert mode.
  "
  " DECSCUSR (set cursor style): blinking bar
  "   CSI 5 SP q
  let &t_SI = "\e[5 q"

  " Set cursor to blinking underline when entering replace mode.
  "
  " DECSCUSR (set cursor style): blinking underline
  "   CSI 3 SP q
  let &t_SR = "\e[3 q"

  " Reset cursor to blinking block when leaving insert or replace mode.
  "
  " DECSCUSR (set cursor style): blinking block
  "   CSI 0 SP q
  let &t_EI = "\e[0 q"
endif

" hterm and tmux support colored and styled underlines, an extension
" originally from kitty (https://sw.kovidgoyal.net/kitty/underlines/).
if &term =~# '\v^%(hterm|tmux)%($|-)'
  " SGR (Character Attributes): Set underline color, RGB
  "   CSI 58 ; 2 ; ; Pr ; Pg ; Pb m
  let &t_8u = "\e[58;2;%lu;%lu;%lum"

  " SGR (Character Attributes): Set underline color, indexed
  "   CSI 58 ; 5 ; Ps m
  let &t_AU = "\e[58;5;%dm"

  " SGR (character attributes): curly underline
  "   CSI 4 : 3 m
  let &t_Cs = "\e[4:3m"

  " SGR (character attributes): normal
  "   CSI m
  let &t_Ce = "\e[m"
else
  " Vim uses the nonstandard Cs termcap entry to mean "undercurl mode", but
  " it's already used as an extension in terminfo for "set cursor color". If
  " we don't support styled underlines, clear Cs to avoid accidentally
  " changing the cursor color (https://github.com/vim/vim/issues/3471).
  "
  " Also clear the other fancy underline settings for good measure.
  let &t_8u = ""
  let &t_AU = ""
  let &t_Cs = ""
  let &t_Ce = ""
endif

" hterm implements the SGR mouse protocol (DECSET 1006) that supports
" terminals wider than 223 columns, but as of February 2022, it claims to be
" XTerm Patch #256 (from 2012) too old to support SGR.
"
" Windows Terminal also supports the SGR mouse protocol, but as of February
" 2022, it claims to be XTerm Patch #10 (from 1996) too old to support SGR.
"
" tmux also supports the SGR mouse protocol, but as of February 2022, doesn't
" report an XTerm patch number at all, and so doesn't get autodetected either.
if has('mouse') && (&term =~# '\v^%(hterm|tmux)%($|-)' || !empty($WT_SESSION))
  set ttymouse=sgr
endif

" Detecting true-color support is tricky. Some terminfo entries (such as
" xterm-direct) declare support for 16 million colors, but this isn't common.
" Other terminals set the COLORTERM environment variable, but this isn't
" perfect either (https://github.com/termstandard/colors).
if has('termguicolors') && (&t_Co == 16777216
    \ || $COLORTERM =~# '\v^%(truecolor|24bit)$'
    \ || &term =~# '\v^%(hterm|tmux)%($|-)' || !empty($WT_SESSION))
  set termguicolors
endif
