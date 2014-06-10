# Make sure various directories are referenced in the search path.
_profile_add_to_path () {
  if [ -d "$1" ] &&
     ! printf '%s\n' "$PATH" | grep -E "(^|:)$1($|:)" /dev/null
  then
    export PATH=$1:$PATH
  fi
}

_profile_add_to_path /usr/games
_profile_add_to_path /opt/haskell-platform/bin

_profile_add_to_path ~/bin
_profile_add_to_path ~/bin/gsutil
_profile_add_to_path ~/.cabal/bin

# Set the preferred editor.
if which vim >/dev/null; then
  export EDITOR=$(which vim)
  export FCEDIT=$(which vim)
  export VISUAL=$(which vim)
elif which vi >/dev/null; then
  export EDITOR=$(which vi)
  export FCEDIT=$(which vi)
  export VISUAL=$(which vi)
elif which nano >/dev/null; then
  export EDITOR=$(which nano)
  export FCEDIT=$(which nano)
  export VISUAL=$(which nano)
elif which pico >/dev/null; then
  export EDITOR=$(which pico)
  export FCEDIT=$(which pico)
  export VISUAL=$(which pico)
fi

# Set the preferred pager.
if which less >/dev/null; then
  export PAGER=$(which less)
elif which more >/dev/null; then
  export PAGER=$(which more)
fi

# Make less a little bit nicer.
type lesspipe >/dev/null 2>&1 && eval "$(lesspipe)"

export LESS='-M -R'

# Don't output noisy, useless diffs when submitting Perforce changelists.
export P4DIFF=$(which true)

# If there is a local .profile file, source that now.
[ -f ~/.profile.local ] && . ~/.profile.local

# If we're running bash, source ~/.bashrc now.
[ -n "$BASH" ] && [ -f ~/.bashrc ] && . ~/.bashrc
