_bb_on_first_load "bb_util_env" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# checkset VAR
function bb_util_env_checkset () {
    local v="$1"
    eval test -z \${$v+x} && return 1 # unset
    eval test -z \${$v}   && return 2 # set, but empty
    return 0
}

# iscmd COMMAND
function bb_util_env_iscmd () {
    command -v "$1" &>/dev/null
}

# inpath VAR ITEM ...
function bb_util_env_inpath () {
    [[ $# -ge 2 ]] || return $__bb_false
    local item
    for item in "${@:2}"; do
        eval [[ ":\${$1}:" =~ ":${item}:" ]] || return $__bb_false
    done
    return $__bb_true
}

# prependpath VAR ITEM ...
function bb_util_env_prependpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval "export $1=\${paths[*]}\${$1:+\${paths:+:}}\${$1}"
}

# appendpath VAR ITEM ...
function bb_util_env_appendpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval "export $1=\${$1}\${$1:+\${paths:+:}}\${paths[*]}"
}

# prependpathuniq VAR ITEM ...
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
    return $__bb_true
}

# swapinpath VAR ITEM1 ITEM2
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
function bb_util_env_printpath () {
    eval printf \"\${$1//${2:-:}/$'\n'}$'\n'\"
}
