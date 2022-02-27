" Vim first uses the system terminfo for most configuration, augmented with some
" extensions from its builtin XTerm termcap when vim_is_xterm returns true.
" After that, Vim asynchronously parses v:termresponse for terminals where t_RV
" is defined, selectively enabling features based on the Secondary DA response.
" We extend this v:termresponse logic a bit ourselves.
function! s:TermResponse()
  " Prefer determining terminal based on v:termresponse (Secondary DA) since it
  " offers more precision than the TERM environment variable.
  let s:term = ''
  if v:termresponse ==# "\e[>0;256;0c"
    " hterm claims to be XTerm Patch #256, which was released in 2010. Since
    " we'll likely never encounter anything so old, we just assume it's hterm.
    let s:term = 'hterm'
  elseif v:termresponse ==# "\e[>0;10;1c"
    " Windows Terminal claims to be XTerm Patch #10, which was released in 1996.
    " Once again, that's absurd, and hence clearly identifies this terminal. :)
    let s:term = 'ms-terminal'
  elseif v:termresponse =~# "\\v^\e\\[\\>84;\\d+;\\d+c$"
    " tmux returns terminal type 'T', which is actually pretty sane.
    let s:term = 'tmux'
  endif

  " If we weren't able to determine a more specific terminal based on
  " v:termresponse, assume any other "xterm" terminal is a real XTerm.
  if s:term ==# '' && &term =~# '\v^xterm%($|-)'
    let s:term = 'xterm'
  endif

  " If the terminal supports it, set the cursor to a blinking bar in insert mode
  " and a blinking underline in replace mode. (This matches the default behavior
  " of the gVim cursor.)
  if index(['hterm', 'ms-terminal', 'tmux', 'xterm'], s:term) >= 0
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
  if index(['hterm', 'tmux'], s:term) >= 0
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
    let &t_Cs = ""
  endif

  " hterm implements the SGR mouse protocol (DECSET 1006) that supports
  " terminals wider than 223 columns, but as of February 2022, it claims to be
  " XTerm Patch #256 (from 2012) too old to support SGR.
  "
  " Windows Terminal also supports the SGR mouse protocol, but as of February
  " 2022, it claims to be XTerm Patch #10 (from 1996) too old to support SGR.
  "
  " tmux also supports the SGR mouse protocol, but as of Vim 8.2, isn't
  " autodetected as an XTerm-like terminal at all.
  if has('mouse') && index(['hterm', 'ms-terminal', 'tmux'], s:term) >= 0
    set ttymouse=sgr
  endif

  " Detecting true-color support is tricky. Some terminfo entries (such as
  " xterm-direct) declare support for 16 million colors, but this isn't common.
  " Other terminals set the COLORTERM environment variable, but this isn't
  " perfect either (https://github.com/termstandard/colors).
  if has('termguicolors') && (&t_Co == 16777216
      \ || index(['truecolor', '24bit'], $COLORTERM) >= 0
      \ || index(['hterm', 'ms-terminal', 'tmux'], s:term) >= 0)
    set termguicolors
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
" Since v:termresponse is set asynchronously from the Secondary DA response
" after we set t_RV, we can only look at $TERM here.
"
" [1]: https://github.com/vim/vim/blob/5c52be40fbab14e050d7494d85be9039f07f7f8f/src/os_unix.c#L2367-L2378
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
