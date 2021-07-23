# @package: core
# Core routines

################################################################################
# Globals
################################################################################

__bb_true=0
__bb_false=1

declare -Ag __bb_loaded=() # _bb_loaded[PKGSTR] = 1
declare -Ag __bb_alias_completions=()

################################################################################
# Functions
################################################################################

# load PKG ...
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

# isloaded PKG
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

# namespace PREFIX
# Aliases bash-boost functions based on prefix
# @arguments:
# - PREFIX: the prefix to use, e.g. "xyz" makes the function
#           bb_cli_arg_loadprompt aliased to xyz_loadprompt
# @notes:
#   If PREFIX is an empty string, the commads just become the
#   base function name (e.g. loadprompt).
#   This will copy over any command completions as well.
function bb_namespace () {
    shopt -s expand_aliases
    local prefix="$1${1:+_}"
    local fcn
    local IFS=$'\n'
    for fcn in $(declare -F); do
        fcn="${fcn/#declare -f }"
        [[ ${fcn:0:3} == "bb_" ]] || continue
        local pkg
        for pkg in "${!__bb_loaded[@]}"; do
            if [[ $fcn =~ ^${pkg}_ ]]; then
                local alias="$prefix${fcn/#${pkg}_}"
                bb_debug "$fcn -> $alias"
                eval "alias $alias=$fcn"
                local cmpl="$(complete -p "$fcn" 2>/dev/null)"
                if [[ -n "$cmpl" ]]; then
                    cmpl=${cmpl% $fcn}
                    bb_debug "$cmpl $alias"
                    eval "$cmpl $alias"
                fi
            fi
        done
    done
}

# debug TEXT
# Log text when debugging is enabled
# @arguments:
# - TEXT: message to be logged in debug mode
# @notes:
#   Set environment variable BB_DEBUG to enable debug mode
function bb_debug () {
    [[ -n $BB_DEBUG ]] && echo "[bb_debug:$$] $1"
}

# issourced
# Check if the script is being sourced
# @returns: 0 if sourced, 1 otherwise
function bb_issourced () {
    # Note: use the bottom of the call stack
    [[ ${BASH_SOURCE[-1]} != $0 ]]
}

# stacktrace
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
