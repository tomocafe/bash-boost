# @package: util/env
# Routines for checking and setting environment variables

_bb_onfirstload "bb_util_env" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# checkset VAR
# Check if an environment variable is set or empty
# @arguments:
# - VAR: name of the variable to check (don't include $)
# @returns: 1 if unset, 2 if set but empty, 0 otherwise
function bb_util_env_checkset () {
    local v="$1"
    eval test -z \${$v+x} && return 1 # unset
    eval test -z \${$v}   && return 2 # set, but empty
    return 0
}

# iscmd COMMAND
# Check if COMMAND is a valid command
# @arguments:
# - COMMAND: name of command to check (e.g., ls)
# @notes:
#   This could be an executable in your PATH, or a function or
#   bash builtin
function bb_util_env_iscmd () {
    command -v "$1" &>/dev/null
}

# inpath VAR ITEM ...
# Checks if items are in the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to find in the path variable
# @returns: 0 if all items are in the path, 1 otherwise
function bb_util_env_inpath () {
    [[ $# -ge 2 ]] || return $__bb_false
    local item
    for item in "${@:2}"; do
        eval [[ ":\${$1}:" =~ ":${item}:" ]] || return $__bb_false
    done
    return $__bb_true
}

# prependpath VAR ITEM ...
# Prepends items to the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to add to the path variable
function bb_util_env_prependpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval "export $1=\${paths[*]}\${$1:+\${paths:+:}}\${$1}"
}

# appendpath VAR ITEM ...
# Appends items to the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to add to the path variable
function bb_util_env_appendpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval "export $1=\${$1}\${$1:+\${paths:+:}}\${paths[*]}"
}

# prependpathuniq VAR ITEM ...
# Prepends unique items to the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to add to the path variable
# @notes:
#   If an item is already in the path, it is not added twice
function bb_util_env_prependpathuniq () {
    [[ $# -ge 2 ]] || return
    local item
    local filtered=()
    for item in "${@:2}"; do
        bb_util_env_inpath "$1" "$item" || filtered+=("$item")
    done
    bb_util_env_prependpath "$1" "${filtered[@]}"
}

# appendpathuniq VAR ITEM ...
# Appends unique items to the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to add to the path variable
# @notes:
#   If an item is already in the path, it is not added twice
function bb_util_env_appendpathuniq () {
    [[ $# -ge 2 ]] || return
    local item
    local filtered=()
    for item in "${@:2}"; do
        bb_util_env_inpath "$1" "$item" || filtered+=("$item")
    done
    bb_util_env_appendpath "$1" "${filtered[@]}"
}

# removefrompath VAR ITEM ...
# Removes items from the colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM: items to remove from the path variable
# @returns: 0 if any item was removed, 1 otherwise
function bb_util_env_removefrompath () {
    [[ $# -ge 2 ]] || return
    local path
    local newpath
    local found=$__bb_false
    for path in "${@:2}"; do
        bb_util_env_inpath "$1" "$path" || continue
        eval newpath=":\${$1}:"
        newpath="${newpath//:$path:/:}"
        newpath="${newpath#:}"
        newpath="${newpath%:}"
        eval export $1="$newpath"
        found=$__bb_true
    done
    return $found
}

# swapinpath VAR ITEM1 ITEM2
# Swaps two items in a colon-separated path variable VAR
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - ITEM1: first item to swap
# - ITEM2: second item to swap
# @returns:
#   0 if swap is successful,
#   1 if either ITEM1 or ITEM2 was not in the path
#   2 if insufficient arguments were supplied (less than 3)
#   3 for internal error
function bb_util_env_swapinpath () {
    [[ $# -eq 3 ]] || return 2
    bb_util_env_inpath "$1" "$2" || return $__bb_false
    bb_util_env_inpath "$1" "$3" || return $__bb_false
    bb_util_env_inpath "$1" "@SWAPPING@" && return 3 # sentinel value
    local newpath
    eval newpath=":\$$1:"
    newpath="${newpath//:$2:/:@SWAPPING@:}"
    newpath="${newpath//:$3:/:$2:}"
    newpath="${newpath//:@SWAPPING@:/:$3:}"
    newpath="${newpath#:}"
    newpath="${newpath%:}"
    eval export $1="$newpath"
    return $__bb_true
}

# printpath VAR [SEP]
# Prints a path variable separated by SEP, one item per line
# @arguments:
# - VAR: path variable, e.g. PATH (do not use $)
# - SEP: separator character, defaults to :
function bb_util_env_printpath () {
    eval printf \"\${$1//${2:-:}/$'\n'}$'\n'\"
}
