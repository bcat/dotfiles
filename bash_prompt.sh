# Disable variable expansion in prompt strings.
shopt -u promptvars

# Determine if we have tput to generate terminal escape codes. Most Unix systems
# have a tput binary, but Cygwin doesn't have one by default, so we have to
# fall-back to no terminal colors/attributes if we can't find tput.
if type tput >/dev/null 2>&1; then
  _bash_prompt_num_colors=$(tput colors)

  _bash_prompt_term_reset=$(tput sgr0)
  _bash_prompt_term_bold=$(tput bold)
else
  _bash_prompt_num_colors=-1

  _bash_prompt_term_reset=
  _bash_prompt_term_bold=
fi

# Set up terminal colors for various bits of the prompt. These look best with a
# color palette matching my Vim theme <https://github.com/bcat/abbott.vim>;
# however, these color choices should look fine with any reasonable palette.
# Note that we intentionally don't use color 12 (bold color 4) because it looks
# very low-contrast in the Linux console color palette.
if (( $_bash_prompt_num_colors >= 16 )); then
  # For terminals that support high-intensity colors (i.e., terminals supporting
  # at least 16 total colors), use those directly.
  _bash_prompt_term_bright_red=$(tput setaf 9)
  _bash_prompt_term_bright_green=$(tput setaf 10)
  _bash_prompt_term_orange=$(tput setaf 3)
  _bash_prompt_term_blue=$(tput setaf 4)
  _bash_prompt_term_bright_magenta=$(tput setaf 13)
  _bash_prompt_term_bright_cyan=$(tput setaf 14)
  _bash_prompt_term_bright_white=$(tput setaf 15)
elif (( $_bash_prompt_num_colors >= 8 )); then
  # For terminals that only support 8 colors, use the bold attribute, which many
  # terminals (including the Linux and Cygwin consoles) will render as bright.
  _bash_prompt_term_bright_red=$_bash_prompt_term_bold$(tput setaf 1)
  _bash_prompt_term_bright_green=$_bash_prompt_term_bold$(tput setaf 2)
  _bash_prompt_term_orange=$_bash_prompt_term_reset$(tput setaf 3)
  _bash_prompt_term_blue=$_bash_prompt_term_reset$(tput setaf 4)
  _bash_prompt_term_bright_magenta=$_bash_prompt_term_bold$(tput setaf 5)
  _bash_prompt_term_bright_cyan=$_bash_prompt_term_bold$(tput setaf 6)
  _bash_prompt_term_bright_white=$_bash_prompt_term_bold$(tput setaf 7)
else
  # For terminals with less than the standard 8 colors, render in monochrome,
  # but still use the bold attribute if we found it above.
  _bash_prompt_term_bright_red=
  _bash_prompt_term_bright_green=
  _bash_prompt_term_orange=
  _bash_prompt_term_blue=
  _bash_prompt_term_bright_cyan=
  _bash_prompt_term_bright_magenta=
  _bash_prompt_term_bright_white=
fi

# Set a flag if the system has git installed.
if type git >/dev/null 2>&1; then
  _bash_prompt_have_git=1
fi

preexec () {
  local cmd_line job cmd

  # Split the command line into multiple words.
  read -a cmd_line <<<"$1"

  # Find job specification.
  case "${cmd_line[0]}" in
    fg) [[ -n ${cmd_line[1]} ]] && job=${cmd_line[1]} || job=%% ;;
    %*) job=${cmd_line[0]} ;;
  esac

  # Get real command line.
  if [[ -n $job ]] && jobs "$job" 2>/dev/null; then
    # If we're bring a background job to the foreground, extract the job's
    # original command line.
    [[ $(jobs "$job") =~ [^\ ]+\ +[^\ ]+\ +(.*) ]] && cmd=${BASH_REMATCH[1]}
  else
    # Otherwise, recombine the command line we split earlier. Note that this
    # will normalize all whitespace down to a single space, just like a job
    # table entry's command line.
    cmd=${cmd_line[@]}
  fi

  # Set the terminal title.
  _bash_prompt_title "$cmd"
}

precmd () {
  # Reset prompt variables.
  _bash_prompt_col=0
  PS1=
  PS2='> '
  PS3='#? '
  PS4='+ '

  # Build the prompt.
  _bash_prompt_ps1_build_machine
  _bash_prompt_ps1_build_status
  _bash_prompt_ps1_build_directory
  _bash_prompt_ps1_append $'\n'
  _bash_prompt_ps1_build_symbol
  _bash_prompt_ps1_escape "$_bash_prompt_term_reset"
  _bash_prompt_ps1_escape "$(_bash_prompt_title)"
}

_bash_prompt_ps1_build_machine () {
  _bash_prompt_ps1_escape "$_bash_prompt_term_blue"
  _bash_prompt_ps1_append "$USER"
  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_white"
  _bash_prompt_ps1_append @
  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_magenta"
  _bash_prompt_ps1_append "$(hostname -s)"
}

_bash_prompt_ps1_build_status () {
  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_white"
  _bash_prompt_ps1_build_jobs
  _bash_prompt_ps1_build_git
}

_bash_prompt_ps1_build_jobs () {
  _bash_prompt_ps1_append ' J:'

  local count=$(jobs | wc -l)

  if (( count == 0 )); then
    _bash_prompt_ps1_escape "$_bash_prompt_term_bright_green"
  elif (( count == 1 )); then
    _bash_prompt_ps1_escape "$_bash_prompt_term_orange"
  else
    _bash_prompt_ps1_escape "$_bash_prompt_term_bright_red"
  fi

  _bash_prompt_ps1_append "$count"

  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_white"
}

_bash_prompt_ps1_build_git() {
  [[ -n $_bash_prompt_have_git ]] || return;
  local status
  status=$(git status --porcelain -b 2>/dev/null) || return
  _bash_prompt_ps1_append ' G:'

  local OLDIFS=$IFS IFS=$'\n'
  local lines=($status) IFS=OLDIFS

  # The first line of the `git status` output contains information on the
  # current branch. Grab that info; then shift the first line off so the array
  # only contains lines pertaining to particular files.
  local branch_info=${lines[0]#\## }
  unset lines[0]

  # Parse the branch name out, ignoring remote information.
  local branch_name=${branch_info%%...*}
  local status_char

  for line in "${lines[@]}"; do
    if [[ ${line:0:2} == '??' ]]; then
      status_char=? # Untracked file present.
    else
      status_char=! # Tracked file modified.
      break
    fi
  done

  if [[ $branch_info =~ \[(ahead|behind)\ [[:digit:]]+\] ]]; then
    if [[ ${BASH_REMATCH[1]} == behind ]]; then
      _bash_prompt_ps1_escape "$_bash_prompt_term_bright_red"
    else
      _bash_prompt_ps1_escape "$_bash_prompt_term_orange"
    fi
  else
    _bash_prompt_ps1_escape "$_bash_prompt_term_bright_green"
  fi

  _bash_prompt_ps1_append "$branch_name$status_char"

  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_white"
}

_bash_prompt_ps1_build_directory () {
  _bash_prompt_ps1_escape "$_bash_prompt_term_bright_cyan"
  _bash_prompt_ps1_append ' '
  _bash_prompt_ps1_append \
      "$(_bash_prompt_truncate "${PWD/#$HOME/'~'}" \
      $((COLUMNS - _bash_prompt_col)) left)"
}

_bash_prompt_ps1_build_symbol () {
  if (( UID == 0 )); then
    _bash_prompt_ps1_escape \
        "$_bash_prompt_term_bright_red$_bash_prompt_term_bold"
    _bash_prompt_ps1_append '# '
  else
    _bash_prompt_ps1_escape \
        "$_bash_prompt_term_bright_white$_bash_prompt_term_bold"
    _bash_prompt_ps1_append '$ '
  fi
}

# _bash_prompt_ps1_append STRING
#
# Append STRING to PS1. Backslashes will be doubled to ensure proper display.
# _bash_prompt_col will be updated as appropriate.
_bash_prompt_ps1_append () {
  local i; for (( i = 0; i < ${#1}; ++i )); do
    if [[ ${1:i:1} == $'\n' ]]; then
      _bash_prompt_col=0
    else
      (( ++_bash_prompt_col ))
    fi
  done

  PS1=$PS1${1//\\/\\\\}
}

# _bash_prompt_ps1_escape STRING
#
# Append STRING to PS1. Backslashes will be doubled to ensure proper display.
# \[ and \] markers will be added to mark the string as an escape sequence.
# _bash_prompt_col will not be updated.
_bash_prompt_ps1_escape () {
  PS1=$PS1\\[${1//\\/\\\\}\\]
}

# _bash_prompt_title [COMMAND]
#
# Output an escape sequence to set the terminal's title bar. Only works on
# xterm-like terminals. If COMMAND is not provided, the name of the currently-
# executing shell will be substituted.
_bash_prompt_title () {
  if [[ $TERM =~ ^(cygwin|rxvt|screen|xterm)(-|$) ]]; then
    # OSC 2 ; term_window_title BEL
    printf '\e]2;%s\a' "${1:-$0} (${PWD/#$HOME/'~'})"
  fi
}

# _bash_prompt_truncate STRING LENGTH [MODE]
#
# Output STRING truncated to LENGTH characters. MODE, which may be "right"
# (the default) or "left", controls which side of the string to truncate on.
_bash_prompt_truncate () {
  if (( ${#1} < $2 )); then
    printf %s "$1"
  elif [[ $3 == left ]]; then
    printf %s "...${1:3-$2}"
  else
    printf %s "${1:0:$2-3}..."
  fi
}
