# @package: util/list
# Routines for common list operations

_bb_onfirstload "bb_util_list" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# join [-v VAR] SEP ITEM ...
# Joins the list of items into a string with the given separator
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - SEP: separator
# - ITEM: a list item 
function bb_join () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local IFS="$1"
    shift
    _bb_result "$*"
}

# split [-V LISTVAR] SEP STR
# Splits a string into a list based on a separator
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - SEP: separator
# - STR: string to split
function bb_split () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local IFS=$1
    local -
    set -f # turn off globbing, local to this function
    local arr=()
    local token
    while IFS= read -r token; do
        arr+=( $token ) # no quotes around $token -- important!
    done <<< "$2"
    IFS=' ' _bb_result "${arr[@]}"
}

# inlist TARGET LIST ...
# Checks if a target item exists in a given list
# @arguments:
# - TARGET: the search target
# - LIST: a list item
# @returns: 0 if found, 1 otherwise
function bb_inlist () {
    local target="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$target" ]] && return $__bb_true
    done
    return $__bb_false
}

# push LISTVAR ITEM
# Pushes an item to a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - ITEM: item to push
function bb_push () {
    eval "$1=("\${$1[@]}" "$2")"
}

# pop LISTVAR
# Pops an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_pop () {
    eval "unset $1[-1]"
}

# unshift LISTVAR ITEM
# Unshifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - ITEM: item to unshift
function bb_unshift () {
    eval "$1=("$2" "\${$1[@]}")"
}

# shift LISTVAR
# Shifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_shift () {
    eval "unset $1[0]"
}

function _bb_util_list_base_sort () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local IFS=$'\n'
    local sorted=( $(sort "${__bb_util_list_sort_opts[@]}" <<<"$*") )
    unset IFS
    _bb_result "${sorted[@]}"
}

# sort [-V LISTVAR] ITEM ...
# Sorts the items of a list in lexicographic ascending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sort () {
    _bb_util_list_base_sort "$@"
}

# sortdesc [-V LISTVAR] ITEM ...
# Sorts the items of a list in lexicographic descending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortdesc () {
    __bb_util_list_sort_opts=(-r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnums [-V LISTVAR] ITEM ...
# Sorts the items of a list in numerical ascending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortnums () {
    __bb_util_list_sort_opts=(-g)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnumsdesc [-V LISTVAR] ITEM ...
# Sorts the items of a list in numerical descending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortnumsdesc () {
    __bb_util_list_sort_opts=(-g -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthuman [-V LISTVAR] ITEM ...
# Sorts the items of a list in human-readable ascending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
# @notes:
#   Human readable, e.g., 1K, 2M, 3G
function bb_sorthuman () {
    __bb_util_list_sort_opts=(-h)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthumandesc [-V LISTVAR] ITEM ...
# Sorts the items of a list in human-readable descending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
# @notes:
#   Human readable, e.g., 1K, 2M, 3G
function bb_sorthumandesc () {
    __bb_util_list_sort_opts=(-h -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# uniq [-V LISTVAR] ITEM ...
# Filters an unsorted list to include only unique items
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_uniq () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    declare -A __bb_util_list_uniq_items=()
    local dedup=()
    local item
    for item in "$@"; do
        [[ ${__bb_util_list_uniq_items[$item]+set} ]] && continue
        __bb_util_list_uniq_items[$item]=1
        dedup+=("$item")
    done
    unset __bb_util_list_uniq_items
    _bb_result "${dedup[@]}"
}

# uniqsorted [-V LISTVAR] ITEM ...
# Filters an sorted list to include only unique items
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
# @notes:
#   Faster than uniq, but requires the list to be pre-sorted
function bb_uniqsorted () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local dedup=("$1")
    local prev="$1"
    local item
    for item in "${@:2}"; do
        [[ $item == $prev ]] && continue
        prev="$item"
        dedup+=("$item")
    done
    _bb_result "${dedup[@]}"
}
