# @package: interactive/cmd
# Miscellaneous interactive commands

_bb_onfirstload "bb_interactive_cmd" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# mcd DIR
# Make director(ies) and change directory to the last one
# @arguments:
# - DIR: usually a single directory to be made, but all arguments are passed to 
#        mkdir and the last argument is then passed to cd if mkdir is successful
function bb_interactive_cmd_mcd () {
    command mkdir "$@" && command cd "${@: -1}"
}

# up [DIR]
# Change directory up
# @arguments:
# - DIR: go to this directory, otherwise defaults to .. if no DIR specified
# @notes:
#   Most useful with the associated command completion. After pressing TAB,
#   the current working directory is populated, and with each further TAB,
#   a directory is removed, moving you up the directory stack. Once you see
#   the upward directory you want to go to, hit ENTER
function bb_interactive_cmd_up () {
    cd ${1:-..}
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
complete -o nospace -F _bb_interactive_cmd_up_completion bb_interactive_cmd_up
