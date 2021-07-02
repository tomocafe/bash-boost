__bb_this="bb_util_env"
bb_on_first_load "$__bb_this" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# checkset VAR
bb_util_env_checkset () {
    local v="$1"
    eval test -z \${$v+x} && return 1 # unset
    eval test -z \${$v}   && return 2 # set, but empty
    return 0
}

# iscmd COMMAND
bb_util_env_iscmd () {
    command -v "$1" &>/dev/null
}

# inpath VAR ITEM
bb_util_env_inpath () {
    [[ $# -ge 2 ]] || return $_bb_false
    local item
    for item in "${@:2}"; do
        eval [[ ":\${$1}:" =~ ":${item}:" ]] || return $_bb_false
    done
    return $_bb_true
}

# prependpath VAR ITEM
bb_util_env_prependpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval export $1=\${paths[*]}\${$1:+\${paths:+:}}\${$1}
}

# appendpath VAR ITEM
bb_util_env_appendpath () {
    [[ $# -ge 2 ]] || return
    local paths=("${@:2}")
    local IFS=':'
    eval export $1=\${$1}\${$1:+\${paths:+:}}\${paths[*]}
}

# prependpathuniq VAR ITEM
bb_util_env_prependpathuniq () {
    [[ $# -ge 2 ]] || return
    local item
    local filtered=()
    for item in "${@:2}"; do
        bb_util_env_inpath "$1" "$item" || filtered+=("$item")
    done
    bb_util_env_prependpath "$1" "${filtered[@]}"
}

# appendpathuniq VAR ITEM
bb_util_env_appendpathuniq () {
    [[ $# -ge 2 ]] || return
    local item
    local filtered=()
    for item in "${@:2}"; do
        bb_util_env_inpath "$1" "$item" || filtered+=("$item")
    done
    bb_util_env_appendpath "$1" "${filtered[@]}"
}

# removefrompath VAR ITEM
bb_util_env_removefrompath () {
    :
}

# swapinpath VAR ITEM1 ITEM2
bb_util_env_swapinpath () {
    :
}

# printpath VAR [SEP]
bb_util_env_printpath () {
    eval printf \"\${$1//${2:-:}/$'\n'}$'\n'\"
}
