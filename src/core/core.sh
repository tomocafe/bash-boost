################################################################################
# Globals
################################################################################

_bb_true=0
_bb_false=1

declare -Ag _bb_loaded=() # _bb_loaded[PKGSTR] = 1

################################################################################
# Functions
################################################################################

# load PKG ...
bb_load () {
    local pkg
    for pkg in "$@"; do
        if [[ -d "$BB_ROOT/$pkg" ]] && [[ -e "$BB_ROOT/$pkg/_load.sh" ]]; then
            source "$BB_ROOT/$pkg/_load.sh"
        elif [[ -r "$BB_ROOT/${pkg%.sh}.sh" ]]; then
            [[ "${pkg##*/}" =~ ^_ ]] && continue
            source "$BB_ROOT/${pkg%.sh}.sh"
        fi
    done
}

bb_is_loaded () {
    [[ ${_bb_loaded["$1"]+set} ]]
}

bb_set_loaded () {
    _bb_loaded["$1"]=1
}

bb_on_first_load () {
    bb_is_loaded "$1" && return $_bb_false
    bb_set_loaded "$1"
    bb_debug "loaded $1"
    return $_bb_true
}

# namespace PREFIX
bb_namespace () {
    shopt -s expand_aliases
    local prefix="$1${1:+_}"
    local fcn
    local IFS=$'\n'
    for fcn in $(declare -F); do
        fcn="${fcn/#declare -f }"
        [[ ${fcn:0:3} == "bb_" ]] || continue
        local pkg
        for pkg in "${!_bb_loaded[@]}"; do
            if [[ $fcn =~ ^${pkg}_ ]]; then
                local alias="$prefix${fcn/#${pkg}_}"
                bb_debug "$fcn -> $alias"
                eval "alias $alias=$fcn"
            fi
        done
    done
}

bb_debug () {
    [[ -n $BB_DEBUG ]] && echo "[bb_debug:$$] $1"
}
