# If this isn't an interactive shell, bail out now.
case "$-" in
  *i*) ;;
  *) return ;;
esac

# If we have fortune, print a fortune cookie.
if command -v fortune >/dev/null; then
  if command -v cowsay >/dev/null; then
    fortune ~/fortunes/hitchhiker | cowsay -n
  else
    printf '\n'
    fortune ~/fortunes/hitchhiker
    printf '\n'
  fi
fi

# Set shell options and variables.
shopt -s checkhash # Confirm locations of hashed commands.
shopt -s checkwinsize # Update LINES and COLUMNS variables after each command.
shopt -s histappend # Append to history file instead of overwriting it.
shopt -s histverify # Verify history substitutions before executing them.

# Remove duplicate history entries; don't save commands beginning with spaces.
HISTCONTROL=ignoreboth:erasedups

# Increase command history size.
HISTSIZE=65535

# Emulate ZSH's `precmd` and `preexec` functions. Credit for the technique
# goes to Glyph Lefkowitz. See also: <http://glyf.livejournal.com/63106.html>.
_bashrc_prompt_command () {
  [ "$(type -t precmd)" = function ] && precmd
  _bashrc_run_preexec=1
}

_bashrc_debug_trap () {
  if [ -n "$_bashrc_run_preexec" ] && [ -z "$COMP_LINE" ] && [ -t 1 ]; then
    if [ "$BASH_COMMAND" != _bashrc_prompt_command ] &&
        [ "$(type -t preexec)" = function ]; then
      preexec "$(history 1 |
          sed 's/^[[:space:]]*[[:digit:]]\{1,\}[[:space:]]*//')"
    fi
    unset _bashrc_run_preexec
  fi
  return 0
}

PROMPT_COMMAND=_bashrc_prompt_command
trap _bashrc_debug_trap DEBUG

set -o functrace
shopt -s extdebug

# Give certain commands some color.
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ls='ls --color=auto'

if command -v dircolors >/dev/null; then
  eval "$(dircolors ~/.config/lscolors/LS_COLORS)"
fi

# Set up for muOS development.
if [ -d ~/sdk/muos ]; then
  export REPO_ROOT=src
  export REPO_FRONTEND=muos-frontend
  export REPO_INTERNAL=muos-internal
  export REPO_LANGUAGE=muos-language
fi

# Customize the prompt.
. ~/.bash_prompt.sh

# Set up some fancy auto-completion.
[ -f /etc/bash_completion ] && . /etc/bash_completion

# Set up environment for Zephyr (https://www.zephyrproject.org/).
[ -f ~/.zephyrrc ] && . ~/.zephyrrc

# If there is a local .bashrc file, source that now.
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
