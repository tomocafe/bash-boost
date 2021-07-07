_bb_on_first_load "bb_interactive_cmd" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# mcd DIR
bb_interactive_cmd_mcd () {
    command mkdir "$@" && command cd "${@: -1}"
}

# up DIR
bb_interactive_cmd_up () {
    cd ${1:-..}
}

_bb_interactive_cmd_up_completion () {
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
complete -o nospace -F _bb_interactive_cmd_up_completion bb_interactive_cmd_up
