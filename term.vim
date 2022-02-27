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

  " Vim uses the nonstandard Cs termcap entry to mean "undercurl mode", but it's
  " already used as an extension in terminfo meaning "set cursor color". We
  " override it to have Vim's intended meaning.
  if index(['hterm', 'tmux'], s:term) >= 0
    " SGR (character attributes): curly underline (kitty extension)
    "   CSI 4 : 3 m
    let &t_Cs = "\e[4:3m"

    " SGR (character attributes): normal
    "   CSI m
    let &t_Ce = "\e[m"
  else
    " Clear t_Cs for unrecognized terminals to avoid accidentally changing the
    " cursor color (https://github.com/vim/vim/issues/3471).
    let &t_Cs = ""
    let &t_Ce = ""
  endif

  " As of Vim 8.2, Vim clears the nonstandard 8u termcap entry in all but a few
  " terminals because "it does not work for the real XTerm; it resets the
  " background color." However, hterm supports it just fine, so we need to reset
  " it now (after Vim's already cleared it).
  if s:term ==# 'hterm'
    " SGR (character attributes): set underline color, RGB (kitty extension)
    "   CSI 58 : 2 : : Pr : Pg : Pb m
    "
    " Use colon instead of semicolon as subparameter delimiter or else mintty
    " parses this as two separate SGR codes: 58 and 2).
    let &t_8u="\e[58:2::%lu:%lu:%lum"
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

" When vim_is_xterm returns false, Vim's builtin XTerm termcap isn't applied, so
" several Vim-specific termcap extensions go missing. For terminals we know
" behave like XTerm, manually set these values.
"
" Since v:termresponse isn't available until some time after we set t_RV, we can
" only look at $TERM here.
"
" See https://github.com/vim/vim/issues/6609 for more details.
if $TERM =~# '\v^%(hterm|tmux)%(-|$)'
  " SGR (character attributes): set underline color, indexed (kitty extension)
  "   CSI 58 : 5 : Ps m
  "
  " Use colon instead of semicolon as subparameter delimiter or else mintty
  " parses this as two separate SGR codes: 58 and 5).
  let &t_AU="\e[58:5:%dm"

  " Send device attributes (secondary DA): request terminal identification
  "   CSI > c
  let &t_RV = "\e[>c"

  " SGR (character attributes): set foreground color, RGB
  "   CSI 38 ; 2 ; Pr ; Pg ; Pb m
  let &t_8f = "\e[38;2;%lu;%lu;%lum"

  " SGR (character attributes): set foreground color, RGB
  "   CSI 48 ; 2 ; Pr ; Pg ; Pb m
  let &t_8b = "\e[48;2;%lu;%lu;%lum"

  " SGR (character attributes): set underline color, RGB (kitty extension)
  "   CSI 58 : 2 : : Pr : Pg : Pb m
  "
  " Use colon instead of semicolon as subparameter delimiter or else mintty
  " parses this as two separate SGR codes: 58 and 2).
  let &t_8u="\e[58:2::%lu:%lu:%lum"

  " DECSET (DEC private mode set): bracketed paste mode
  "   CSI ? 2 0 0 4 h
  let &t_BE = "\e[?2004h"

  " DECRST (DEC private mode reset): bracketed paste mode
  "   CSI ? 2 0 0 4 l
  let &t_BD = "\e[?2004l"

  " DECSCUSR (set cursor style)
  "   CSI Ps SP q
  let &t_SH = "\e[%p1%d q"

  " XTWINOPS (save title): window title
  "   CSI 2 2 ; 2 t
  let &t_ST = "\e[22;2t"

  " XTWINOPS (restore title): window title
  "   CSI 2 3 ; 2 t
  let &t_RT = "\e[23;2t"

  " Start of bracketed paste
  "   ESC [ 2 0 0 ~
  let &t_PS = "\e[200~"

  " End of bracketed paste
  "   ESC [ 2 0 1 ~
  let &t_PE = "\e[201~"
endif
