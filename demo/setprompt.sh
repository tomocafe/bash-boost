#!/bin/bash

# Demo: setting the dynamic prompt

source ../bash-boost-*/bash-boost.sh

bb_load cli
bb_load interactive/prompt
bb_namespace bb

# Parse command line arguments
bb_addflag n:twoline "Use two-line prompt"
bb_setprog "${BASH_SOURCE[0]##*/}"
bb_parseargs "$@"

if [[ ${BASH_SOURCE[0]} == $0 ]]; then
    bb_fatal "this script must be sourced"
fi

# Cache TTY_NUM
TTY_NUM="$(command tty)"
TTY_NUM="${TTY_NUM##*/}"

# Define functions for outputting to prompt regions
preprompt () {
    local rccolor
    [[ $BB_PROMPT_LASTRC -eq 0 ]] && rccolor=green || rccolor=bright_red
    bb_promptcolor "$rccolor" "┌─"
}
lhs () {
    bb_promptcolor magenta "$USER"
    echo -n "@"
    bb_promptcolor yellow "$HOSTNAME"
    echo -n ":"
    bb_promptcolor blue "$TTY_NUM"
}
rhs () {
    local cwd="${PWD/#$HOME/$'~'}"
    local dirname="${cwd##*/}"
    local dirpath="${cwd%/*}"
    if [[ $dirname != $dirpath ]]; then
        dirpath+="/"
        if (( ${#dirpath} + ${#dirname} < ${BB_PROMPT_REM} )); then
            echo -n "$dirpath"
        fi
    fi
    bb_promptcolor bright_white "$dirname"
}
sep () {
    echo -n " "
}
prompt () {
    local rccolor
    local promptchar
    [[ $BB_PROMPT_LASTRC -eq 0 ]] && rccolor=green || rccolor=bright_red
    [[ $EUID -eq 0 ]] && promptchar='#' || promptchar='$'
    bb_promptcolor "$rccolor" "${promptchar} "
}

if bb_checkopt twoline; then
    bb_setpromptleft preprompt sep lhs
    bb_setpromptright rhs
    bb_setpromptnextline prompt
else
    bb_setpromptleft lhs sep prompt
fi

# Load prompt
bb_loadprompt
bb_info "Restore previous prompt with bb_unloadprompt"
