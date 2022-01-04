# @package: core
# Core routines

################################################################################
# Globals
################################################################################

__bb_true=0
__bb_false=1

declare -Ag __bb_loaded # _bb_loaded[PKGSTR] = 1
declare -Ag __bb_alias_completions

__bb_outvars=()

################################################################################
# Functions
################################################################################

# bb_load PKG ...
# Loads a module or package
# @arguments:
# - PKG: either a package (e.g. cli/arg) or a whole module (e.g. cli)
# @notes:
#   Each package only loads once; if you happen to load one twice, the second 
#   time has no effect
function bb_load () {
    local pkg
    for pkg in "$@"; do
        if [[ -d "$BB_ROOT/$pkg" ]] && [[ -e "$BB_ROOT/$pkg/_load.sh" ]]; then
            bb_debug "sourcing $BB_ROOT/$pkg/_load.sh"
            source "$BB_ROOT/$pkg/_load.sh"
        elif [[ -r "$BB_ROOT/${pkg%.sh}.sh" ]]; then
            [[ "${pkg##*/}" =~ ^_ ]] && continue
            bb_debug "sourcing $BB_ROOT/${pkg%.sh}.sh"
            source "$BB_ROOT/${pkg%.sh}.sh"
        fi
    done
}

# bb_isloaded PKG
# Checks if a package is loaded already
# @arguments:
# - PKG: package name in internal format, e.g. bb_cli_arg
# @returns: 0 if loaded, 1 otherwise
function bb_isloaded () {
    [[ ${__bb_loaded["$1"]+set} ]]
}

# setloaded PKG
function _bb_setloaded () {
    __bb_loaded["$1"]=1
    bb_debug "loaded $1"
}

# onfirstload PKG
function _bb_onfirstload () {
    bb_isloaded "$1" && return $__bb_false
    _bb_setloaded "$1"
    return $__bb_true
}

# bb_debug TEXT
# Log text when debugging is enabled
# @arguments:
# - TEXT: message to be logged in debug mode
# @notes:
#   Set environment variable BB_DEBUG to enable debug mode
function bb_debug () {
    [[ -n $BB_DEBUG ]] && echo "[bb_debug:$$] $1"
}

# bb_issourced
# Check if the script is being sourced
# @returns: 0 if sourced, 1 otherwise
function bb_issourced () {
    # Note: use the bottom of the call stack
    [[ ${BASH_SOURCE[${#BASH_SOURCE[@]}-1]} != $0 ]]
}

# bb_stacktrace
# Print a stack trace to stderr
function bb_stacktrace () {
    local -i i
    local depth="${#FUNCNAME[@]}"
    local maxwidth=0
    for (( i=1; i<$depth; i++ )); do
        [[ ${#FUNCNAME[$i]} -gt $maxwidth ]] && maxwidth=${#FUNCNAME[$i]}
    done
    for (( i=1; i<$depth; i++ )); do
        printf "%-${#depth}d  %-${maxwidth}s  %s:%d\n" "$i" "${FUNCNAME[$i]}" "${BASH_SOURCE[$i]}" "${BASH_LINENO[$i-1]}" 1>&2
    done
}

# glopts
# Parse global command opts
# @notes:
#   Leading global options (at start of args):
#     -v VAR: saves the result into VAR
#     -V LISTVAR: saves the list result into LISTVAR
#     --: stops parsing global opts
#   Trailing global options (at end of args):
#     -: read remaining arguments from stdin
#   Usage: _bb_glopts "$@"; set -- "${__bb_args[@]}"
function _bb_glopts () {
    # Look for starting -v, -V, --
    local stop=false
    __bb_outvars+=("") # push empty
    case "$1" in
        -v) __bb_outvars[${#__bb_outvars[@]}-1]="v:$2"; shift 2;;
        -V) __bb_outvars[${#__bb_outvars[@]}-1]="V:$2"; shift 2;;
        --) stop=true; shift 1;;
    esac
    __bb_args=("$@") # copy args after shifting out -v, -V, --
    $stop && return # encountered --
    # Look for trailing - (read args from stdin)
    case "${@: -1}" in
        -)
            unset __bb_args[${#_bb_args[@]}-1]
            readarray -t -O ${#__bb_args[@]} __bb_args # append args from stdin to __bb_args
            ;;
    esac
}

# result VAL ...
# Outputs the result either to a variable or to stdout
function _bb_result () {
    local outvar="${__bb_outvars[${#__bb_outvars[@]}-1]}"
    unset __bb_outvars[${#__bb_outvars[@]}-1] # pop
    case "${outvar:0:1}" in
        v) # to scalar variable
            printf -v "${outvar:2}" '%s' "$1"
            ;;
        V) # to list variable
            local quoted=()
            local item
            for item in "$@"; do
                quoted+=("\"$item\"")
            done
            eval "${outvar:2}=("${quoted[@]}")"
            ;;
        *) # to stdout
            echo "$*"
            ;;
    esac
}

# bb_cleanup
# Clears all functions and variables defined by bash-boost
function bb_cleanup () {
    local line
    # Clear functions
    while read -r line; do
        line="${line#declare -f }"
        [[ $line =~ ^_?bb_ ]] && unset -f "$line"
    done < <(declare -F)
    # Clear variables
    while read -r line; do
        line="${line%%=*}"
        [[ $line =~ ^(BB|__bb)_ ]] && unset "$line"
    done < <(set -o posix; set)
    : # don't use return $__bb_true here, it's now undefined
}
