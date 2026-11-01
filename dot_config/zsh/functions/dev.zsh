#!/usr/bin/env zsh
# ─── dev.zsh ──────────────────────────────────────────────────────────────────
# Developer quality-of-life functions

# port [number] — show what process is listening on a port
# With no argument, lists all listening ports.
port() {
    if [[ -n $1 ]]; then
        [[ $1 == <1-65535> ]] || { print -u2 'usage: port [1-65535]'; return 1 }
        command lsof -nP -iTCP:"$1" -sTCP:LISTEN
    else
        command lsof -nP -iTCP -sTCP:LISTEN
    fi
}

# serve [port] — start a quick HTTP server in the current directory
serve() {
    local p=${1:-8080}
    echo "Serving $(pwd) on http://localhost:${p}"
    python3 -m http.server "$p"
}

# mkenv — scaffold a .env file and open it in $EDITOR
mkenv() {
    local file=${1:-.env}
    [[ -f $file ]] && { echo "$file already exists" >&2; return 1 }
    command cat > "$file" <<'EOF'
# Environment variables
# Copy this file to .env.local and fill in values — never commit secrets!

EOF
    ${EDITOR:-nvim} "$file"
}

# t — smart tree: uses eza tree with sensible depth, respects .gitignore
t() {
    local depth=${1:-2}
    eza --tree --level="$depth" --icons --git-ignore --color=always
}

# json — pretty-print JSON (stdin or file)
json() {
    local formatted
    formatted=$(python3 -m json.tool "$@") || return
    if (( $+commands[bat] )); then
        print -r -- "$formatted" | command bat --language=json --paging=never
    elif (( $+commands[batcat] )); then
        print -r -- "$formatted" | command batcat --language=json --paging=never
    else
        print -r -- "$formatted"
    fi
}

# extract — universal archive extractor
extract() {
    [[ -z $1 ]] && { echo 'usage: extract <archive>' >&2; return 1 }
    [[ ! -f $1 ]] && { echo "$1: not a file" >&2; return 1 }
    case $1 in
        *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
        *.tar.gz|*.tgz)   tar xzf "$1"   ;;
        *.tar.xz)          tar xJf "$1"   ;;
        *.tar.zst)         tar --zstd -xf "$1" ;;
        *.tar)             tar xf "$1"    ;;
        *.bz2)             bunzip2 "$1"   ;;
        *.gz)              gunzip "$1"    ;;
        *.zip)             unzip "$1"     ;;
        *.7z)              7z x "$1"      ;;
        *.xz)              unxz "$1"      ;;
        *.zst)             zstd -d "$1"   ;;
        *)    echo "don't know how to extract '$1'" >&2; return 1 ;;
    esac
}

# size — human-readable disk usage, sorted
size() {
    local dir
    local -a entries=()
    for dir in "${@:-.}"; do
        entries+=("$dir"/*(DN))
    done
    (( $#entries )) || return 0
    command du -sh -- "${entries[@]}" | command sort -h
}
