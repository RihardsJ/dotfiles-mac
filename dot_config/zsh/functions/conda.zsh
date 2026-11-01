#!/usr/bin/env zsh

# Initialise Conda on first use. Preserve an already initialised session.
if (( ! $+functions[conda] )); then
    conda() {
        local conda_init="$HOME/miniconda3/etc/profile.d/conda.sh"
        if [[ ! -r $conda_init ]]; then
            print -u2 -- "Conda initialisation script not found: $conda_init"
            return 127
        fi

        # Conda replaces this loader with its own shell function.
        source "$conda_init" || return
        conda "$@"
    }
fi
