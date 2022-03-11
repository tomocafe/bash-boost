# @package: interactive/cmd
# Miscellaneous interactive commands

_bb_onfirstload "bb_interactive_cmd" || return

bb_load "util/env"
bb_load "util/list"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_mcd DIR
# Make director(ies) and change directory to the last one
# @arguments:
# - DIR: usually a single directory to be made, but all arguments are passed to 
#        mkdir and the last argument is then passed to cd if mkdir is successful
function bb_mcd () {
    command mkdir "$@" && command cd "${@: -1}"
}

# function: bb_up [DIR]
# Change directory up
# @arguments:
# - DIR: go to this directory, otherwise defaults to .. if no DIR specified
# @notes:
#   Most useful with the associated command completion. After pressing TAB,
#   the current working directory is populated, and with each further TAB,
#   a directory is removed, moving you up the directory stack. Once you see
#   the upward directory you want to go to, hit ENTER
function bb_up () {
    # shellcheck disable=SC2164
    cd "${1:-..}"
}

function _bb_interactive_cmd_up_completion () {
    # Note: must be used with complete -o nospace
    # $1=cmd $2=cur $3=pre
    local cwd="${2:-$PWD}"
    local upd="${cwd%/*}"
    if [[ $cwd == '/' ]]; then
        return
    elif [[ $upd == '' ]]; then
        COMPREPLY=('/')
    else
        COMPREPLY=("$upd")
    fi
}
complete -o nospace -F _bb_interactive_cmd_up_completion bb_up

# function: bb_forkterm [ARGS ...]
# Spawn a new terminal instance inheriting from this shell's environment
# @arguments:
# - ARGS: arguments to be appended to the terminal launch command
# @notes:
# - Uses the BB_TERMINAL or TERMINAL environment variable as the command
#   to launch the new terminal instance.
# - Sets the BB_FORKDIR variable for the spawned shell to read.
#   In your shell init file, you can  detect when this variable is set 
#   and change to this directory, if desired.
# - BB_TERMINAL can be a list with arguments, or a string which will be
#   tokenized by space. If your arguments contain spaces, you will need
#   to declare the variable as a list.
function bb_forkterm () {
    local args
    if bb_islist BB_TERMINAL; then
        args=( "${BB_TERMINAL[@]}" )
    else
        local cmd="${BB_TERMINAL:-$TERMINAL}"
        bb_checkset cmd || return "$__bb_false"
        read -r -a args <<<"$cmd"
    fi
    bb_iscmd "${args[0]}" || return "$__bb_false"
    # Putting this in a (temporary) subshell silences the job messages
    # from spawning a background process
    ( BB_FORKDIR=$PWD "${args[@]}" "$@" &>/dev/null & )
}
