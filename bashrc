# If this isn't an interactive shell, bail out now.
case "$-" in
  *i*) ;;
  *) return ;;
esac

# If we have fortune and this is an interactive shell, print a fortune cookie.
if type fortune >/dev/null 2>&1; then
  case "$-" in *i*)
    if type cowsay >/dev/null 2>&1; then
      fortune | cowsay -n
    else
      printf '\n'
      fortune
      printf '\n'
    fi
  ;; esac
fi

# Set shell options and variables.
set -o emacs     # Use emacs-style editing commands.
set -o noclobber # Don't allow redirections to overwrite existing files.

shopt -s cdspell      # Perform typo-correction on cd destination directories.
shopt -s checkhash    # Confirm locations of hashed commands.
shopt -s checkwinsize # Update LINES and COLUMNS variables after each command.
shopt -s cmdhist      # Save multi-line commands in a single history entry.
shopt -s extglob      # Enable extended pattern matching features.
shopt -s histappend   # Append to history file instead of overwriting it.
shopt -s histverify   # Verify history substitutions before executing them.
shopt -s huponexit    # Send SIGHUP to background jobs on exit.
shopt -s xpg_echo     # Make echo POSIX-compliant WRT escape sequences.

HISTCONTROL=ignoredups:erasedups # Remove duplicate history entries.

# Emulate ZSH's precmd and preexec functions. Credit for the technique used
# goes to Glyph Lefkowitz. See also: <http://glyf.livejournal.com/63106.html>.
_bashrc_prompt_command () {
  [ "$(type -t precmd)" = function ] && precmd

  _bashrc_run_preexec=1
}

_bashrc_debug_trap () {
  if [ -n "$_bashrc_run_preexec" ] && [ -z "$COMP_LINE" ]; then
    [ "$BASH_COMMAND" != _bashrc_prompt_command ] &&
      [ "$(type -t preexec)" = function ] && preexec "$(history 1 |
      sed 's/^[[:space:]]*[[:digit:]]\{1,\}[[:space:]]*//')"

    unset _bashrc_run_preexec
  fi

  return 0
}

PROMPT_COMMAND=_bashrc_prompt_command
trap _bashrc_debug_trap DEBUG

set -o functrace
shopt -s extdebug

# Give ls and grep some color.
#
# We use BASH-style function syntax here instead of POSIX syntax because some
# overclever sysadmins/distros decide to alias `ls' in /etc/bash.bashrc, which
# breaks the cleaner-looking `ls () { ... }' method of function definition.
function ls { command ls --color=auto "$@"; }
function grep { command grep --color=auto "$@"; }

# Customize the prompt. (The prompt code is quite long, so it lives in a
# separate file.)
[ -f ~/.bash_prompt ] && . ~/.bash_prompt

# Set up some fancy auto-completion.
[ -f /etc/bash_completion ] && . /etc/bash_completion

# If there is a local .bashrc file, source that now.
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
