#!/usr/bin/env zsh
# ─── navigation.zsh ───────────────────────────────────────────────────────────
# Project-focused directory navigation

# cd with automatic ls after every jump
cd() {
    builtin cd "$@" || return
    if (( $+commands[eza] )); then
        command eza --group-directories-first
    else
        command ls
    fi
}

# mkcd — create directory and cd into it
mkcd() {
    [[ $# == 1 && -n $1 ]] || { print -u2 'usage: mkcd <directory>'; return 1 }
    command mkdir -p -- "$1" && cd -- "$1"
}

# up [n] — go up N directory levels (default: 1)
up() {
    local n=${1:-1} p='' i
    [[ $n == <1-100> ]] || { print -u2 'usage: up [1-100]'; return 1 }
    for (( i=0; i<n; i++ )); do p+='../'; done
    builtin cd "$p"
}

# cdroot — jump to the root of the current git repository
cdroot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null) \
        || { echo 'not inside a git repository' >&2; return 1 }
    builtin cd "$root"
}

# proj — fzf jump to any project under $WORKSPACE (depth 2)
# Shows an eza tree preview on the right side.
proj() {
    [[ -z $WORKSPACE ]] && { echo 'WORKSPACE is not set' >&2; return 1 }
    local dir
    dir=$(fd --type d --max-depth 2 --min-depth 1 . "$WORKSPACE" 2>/dev/null \
        | fzf \
            --prompt='  project  ' \
            --preview='eza --tree --level=2 --icons --color=always {}' \
            --preview-window='right:55%:border-left') \
        || return
    [[ -n $dir ]] && builtin cd -- "$dir"
}

# z wrapper — zoxide with fallback to builtin cd
# (zoxide init zsh already provides `z`; this is a fallback if zoxide is absent)
if ! command -v zoxide &>/dev/null; then
    z() { builtin cd "$@" }
fi
