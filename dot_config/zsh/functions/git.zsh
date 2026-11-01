#!/usr/bin/env zsh
# ─── git.zsh ──────────────────────────────────────────────────────────────────
# Git convenience functions with fzf integration

# gclone — clone a repo and cd into it
gclone() {
    [[ -z $1 ]] && { echo 'usage: gclone <url>' >&2; return 1 }
    git clone "$1" && builtin cd "$(basename "$1" .git)"
}

# gsw — fzf branch switcher (local + remote)
# Preview shows the last 20 commits on the branch.
gsw() {
    local branch local_branch
    branch=$(command git for-each-ref --format='%(refname:short)' refs/heads refs/remotes \
        | command grep -v '/HEAD$' \
        | fzf --prompt='  branch  ' \
            --preview='git log --oneline --graph --color=always -20 {} --' \
            --preview-window='right:55%:border-left') || return
    [[ -n $branch ]] || return 0
    if command git show-ref --verify --quiet "refs/heads/$branch"; then
        command git switch -- "$branch"
    else
        local_branch=${branch#*/}
        if command git show-ref --verify --quiet "refs/heads/$local_branch"; then
            command git switch -- "$local_branch"
        else
            command git switch --track -- "$branch"
        fi
    fi
}

# glog — interactive git log with diff preview
# Enter opens the full commit in less.
glog() {
    command git log --format='%h %s' --all \
        | fzf \
            --prompt='  log  ' \
            --no-sort --reverse --tiebreak=index \
            --preview='git show --color=always {1} --' \
            --preview-window='right:60%:border-left' \
            --bind='enter:execute(git show --color=always {1} -- | less -R)'
}

# gadd — fzf interactive git add
# Multi-select with Tab, shows diff preview for each file.
gadd() {
    local selection
    local -a files
    command git rev-parse --show-toplevel >/dev/null 2>&1 || return
    selection=$(command git -c core.quotePath=false ls-files --modified --others --exclude-standard -z \
        | fzf --read0 --print0 --multi \
            --prompt='  stage  ' \
            --preview='git diff --color=always HEAD -- {} 2>/dev/null; if ! git ls-files --error-unmatch -- {} >/dev/null 2>&1; then git diff --color=always --no-index -- /dev/null {}; fi' \
            --preview-window='right:60%:border-left') || return
    [[ -n $selection ]] || return 0
    files=("${(@0)${selection%$'\0'}}")
    command git add -- "${files[@]}"
}

# gwip — quick "work in progress" commit
gwip() { git add --all && git commit -m "wip: $(date +'%Y-%m-%d %H:%M')" }

# gunwip — undo the last wip commit, leaving changes staged
gunwip() {
    local subject
    subject=$(command git log -1 --format=%s) || return
    if [[ $subject == 'wip: '* ]]; then
        command git reset --soft HEAD~1
    else
        print -u2 'last commit is not a wip commit'
        return 1
    fi
}
