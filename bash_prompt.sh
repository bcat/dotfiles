# Disable variable expansion in prompt strings.
shopt -u promptvars

# If possible, use tput to generate terminal escape codes for colors/attributes.
if type tput >/dev/null 2>&1; then
  _bash_prompt_num_colors=$(tput colors)

  _bash_prompt_title_start=$(tput tsl)
  _bash_prompt_title_end=$(tput fsl)

  # xterm-like terminals don't always have tsl/fsl capabilities in their
  # terminfo entries, but many of them set the nonstandard XT extension,
  # indicating the title can be set with the following escape sequence:
  #
  # OSC 2 ; $window_title BEL
  if [[ -z $_bash_prompt_title_start || -z $_bash_prompt_title_end ]] && \
      tput XT 2>/dev/null; then
    _bash_prompt_title_start=$'\e]2;'
    _bash_prompt_title_end=$'\a'
  fi
fi

# Set up terminal colors for various bits of the prompt. These look best with a
# color palette matching my Vim theme <https://github.com/bcat/abbott.vim>;
# however, these color choices should look fine with any reasonable palette.
if (( _bash_prompt_num_colors >= 16 )); then
  # For terminals that support high-intensity colors (i.e., terminals supporting
  # at least 16 total colors), use those directly.
  _bash_prompt_color_reset=$(tput sgr0)
  _bash_prompt_color_red=$(tput setaf 9)
  _bash_prompt_color_green=$(tput setaf 10)
  _bash_prompt_color_yellow=$(tput setaf 11)
  _bash_prompt_color_magenta=$(tput setaf 13)
  _bash_prompt_color_cyan=$(tput setaf 14)
  _bash_prompt_color_white=$(tput setaf 15)
elif (( _bash_prompt_num_colors >= 8 )); then
  # For terminals that only support 8 colors, use the bold attribute, which many
  # terminals (including the Linux console) will render as bright.
  _bash_prompt_bold=$(tput bold)

  _bash_prompt_color_reset=$(tput sgr0)
  _bash_prompt_color_red=$_bash_prompt_bold$(tput setaf 1)
  _bash_prompt_color_green=$_bash_prompt_bold$(tput setaf 2)
  _bash_prompt_color_yellow=$_bash_prompt_bold$(tput setaf 3)
  _bash_prompt_color_magenta=$_bash_prompt_bold$(tput setaf 5)
  _bash_prompt_color_cyan=$_bash_prompt_bold$(tput setaf 6)
  _bash_prompt_color_white=$_bash_prompt_bold$(tput setaf 7)

  unset _bash_prompt_bold
fi

unset _bash_prompt_num_colors

# Cache some information that shouldn't vary from prompt to prompt.
if type git >/dev/null 2>&1; then
  _bash_prompt_have_git=1
fi

preexec () {
  local cmd_line job cmd

  # Split the command line into multiple words.
  read -ra cmd_line <<<"$1"

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
  # Replace the current user's home directory in $PWD with ~.
  _bash_prompt_path=$PWD
  if [[ $_bash_prompt_path =~ ^"$HOME"(/|$) ]]; then
    _bash_prompt_path=~${_bash_prompt_path#$HOME}
  fi

  # Build the first line of the prompt.
  PS1=
  _bash_prompt_next_col=0

  _bash_prompt_ps1_build_machine
  _bash_prompt_ps1_build_jobs
  _bash_prompt_ps1_build_msys
  _bash_prompt_ps1_build_git
  _bash_prompt_ps1_build_directory

  # Build the second line of the prompt.
  PS1=$PS1$'\n'
  _bash_prompt_next_col=0

  _bash_prompt_ps1_build_symbol

  # Set the terminal title and reset text attributes for user input.
  _bash_prompt_ps1_escape "$(_bash_prompt_title)"
  _bash_prompt_ps1_escape "$_bash_prompt_color_reset"
}

_bash_prompt_ps1_build_machine () {
  _bash_prompt_ps1_escape "$_bash_prompt_color_green"
  _bash_prompt_ps1_append "$USER"
  _bash_prompt_ps1_escape "$_bash_prompt_color_white"
  _bash_prompt_ps1_append @
  _bash_prompt_ps1_escape "$_bash_prompt_color_magenta"
  _bash_prompt_ps1_append "${HOSTNAME%%.*}"
  _bash_prompt_ps1_escape "$_bash_prompt_color_white"
}

_bash_prompt_ps1_build_jobs () {
  # Use arithmetic expansion to filter out leading whitespace from BSD wc.
  local num_jobs=$(($(jobs | wc -l)))

  _bash_prompt_ps1_append ' J:'
  if (( num_jobs == 0 )); then
    _bash_prompt_ps1_escape "$_bash_prompt_color_green"
  elif (( num_jobs == 1 )); then
    _bash_prompt_ps1_escape "$_bash_prompt_color_yellow"
  else
    _bash_prompt_ps1_escape "$_bash_prompt_color_red"
  fi
  _bash_prompt_ps1_append "$num_jobs"
  _bash_prompt_ps1_escape "$_bash_prompt_color_white"
}

_bash_prompt_ps1_build_msys() {
  [[ -n $MSYSTEM ]] || return

  _bash_prompt_ps1_append ' M:'
  case $MSYSTEM in
    MINGW32) _bash_prompt_ps1_escape "$_bash_prompt_color_red" ;;
    MSYS) _bash_prompt_ps1_escape "$_bash_prompt_color_yellow" ;;
    *) _bash_prompt_ps1_escape "$_bash_prompt_color_green" ;;
  esac
  _bash_prompt_ps1_append "$MSYSTEM"
  _bash_prompt_ps1_escape "$_bash_prompt_color_white"
}

_bash_prompt_ps1_build_git() {
  [[ -n $_bash_prompt_have_git ]] || return;

  local status
  status=$(git status --porcelain -b 2>/dev/null) || return

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
      status_char=?  # Untracked file present.
    else
      status_char=!  # Tracked file modified.
      break
    fi
  done

  _bash_prompt_ps1_append ' G:'
  if [[ $branch_info =~ \[(ahead|behind)\ [[:digit:]]+\] ]]; then
    if [[ ${BASH_REMATCH[1]} == behind ]]; then
      _bash_prompt_ps1_escape "$_bash_prompt_color_red"
    else
      _bash_prompt_ps1_escape "$_bash_prompt_color_yellow"
    fi
  else
    _bash_prompt_ps1_escape "$_bash_prompt_color_green"
  fi
  _bash_prompt_ps1_append "$branch_name$status_char"
  _bash_prompt_ps1_escape "$_bash_prompt_color_white"
}

_bash_prompt_ps1_build_directory () {
  _bash_prompt_ps1_escape "$_bash_prompt_color_cyan"
  _bash_prompt_ps1_append ' '
  _bash_prompt_ps1_append "$_bash_prompt_path" truncate
}

_bash_prompt_ps1_build_symbol () {
  if (( UID == 0 )); then
    _bash_prompt_ps1_escape "$_bash_prompt_color_red"
    _bash_prompt_ps1_append '# '
  else
    _bash_prompt_ps1_escape "$_bash_prompt_color_white"
    _bash_prompt_ps1_append '$ '
  fi
}

# _bash_prompt_ps1_append STRING [MODE]
#
# Appends STRING to PS1. Backslashes will be doubled to ensure proper display.
# The string is assumed to not contain newlines. Updates the column counter.
# If MODE is "truncate", the string will be truncated to fit the current line.
_bash_prompt_ps1_append () {
  local str=$1 cols_remaining=$((COLUMNS - _bash_prompt_next_col))
  if [[ $2 == truncate ]] && (( ${#str} > cols_remaining )); then
    (( cols_remaining >= 3 )) || return
    str="...${str:3-$cols_remaining}"
  fi

  PS1=$PS1${str//\\/\\\\}
  (( _bash_prompt_next_col = (_bash_prompt_next_col + ${#str}) % COLUMNS ))
}

# _bash_prompt_ps1_escape STRING
#
# Appends STRING to PS1. Backslashes will be doubled to ensure proper display.
# \[ and \] markers will be added to mark the string as an escape sequence.
# Does not update the column counter.
_bash_prompt_ps1_escape () {
  PS1=$PS1\\[${1//\\/\\\\}\\]
}

# _bash_prompt_title [COMMAND]
#
# Outputs an escape sequence to set the terminal's title bar. If COMMAND is not
# provided, the name of the currently executing shell will be substituted.
_bash_prompt_title () {
  [[ -n $_bash_prompt_title_start && -n $_bash_prompt_title_end ]] || return
  printf %s%s%s "$_bash_prompt_title_start" "${1:-$0} ($_bash_prompt_path)" \
      "$_bash_prompt_title_end"
}
