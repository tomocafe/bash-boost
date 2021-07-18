# @package: util/list
# Routines for common list operations

_bb_on_first_load "bb_util_list" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# join SEP ITEM ...
# Joins the list of items into a string with the given separator
# @arguments:
# - SEP: separator
# - ITEM: a list item 
function bb_util_list_join () {
    local IFS="$1"
    shift
    echo "$*"
}

# split LISTVAR SEP STR
# Splits a string based on a separator and stores the resulting list into
# the specified list variable
# @arguments:
# - LISTVAR: name of variable to store resulting list into (do not include $)
# - SEP: separator
# - STR: string to split
function bb_util_list_split () {
    local IFS=$2
    local -
    set -f # turn off globbing, local to this function
    local arr=()
    local token
    while IFS= read -r token; do
        arr+=( $token ) # no quotes around $token -- important!
    done <<< "$3"
    # Quote tokens
    local quoted=()
    for token in "${arr[@]}"; do
        quoted+=( "\"$token\"" )
    done
    eval "$1=( "${quoted[@]}" )"
}

# inlist TARGET LIST ...
# Checks if a target item exists in a given list
# @arguments:
# - TARGET: the search target
# - LIST: a list item
# @returns: 0 if found, 1 otherwise
function bb_util_list_inlist () {
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
function bb_util_list_push () {
    eval "$1=("\${$1[@]}" "$2")"
}

# pop LISTVAR
# Pops an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_util_list_pop () {
    eval "unset $1[-1]"
}

# unshift LISTVAR ITEM
# Unshifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - ITEM: item to unshift
function bb_util_list_unshift () {
    eval "$1=("$2" "\${$1[@]}")"
}

# shift LISTVAR
# Shifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_util_list_shift () {
    eval "unset $1[0]"
}

function _bb_util_list_base_sort () {
    local IFS=$'\n'
    local sorted=( $(sort "${__bb_util_list_sort_opts[@]}" <<<"$*") )
    unset IFS
    echo "${sorted[*]}"
}

# sort ITEM ...
# Sorts the items of a list in lexicographic ascending order
# @arguments:
# - ITEM: a list item
function bb_util_list_sort () {
    _bb_util_list_base_sort "$@"
}

# sortdesc ITEM ...
# Sorts the items of a list in lexicographic descending order
# @arguments:
# - ITEM: a list item
function bb_util_list_sortdesc () {
    __bb_util_list_sort_opts=(-r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnums ITEM ...
# Sorts the items of a list in numerical ascending order
# @arguments:
# - ITEM: a list item
function bb_util_list_sortnums () {
    __bb_util_list_sort_opts=(-g)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnumsdesc ITEM ...
# Sorts the items of a list in numerical descending order
# @arguments:
# - ITEM: a list item
function bb_util_list_sortnumsdesc () {
    __bb_util_list_sort_opts=(-g -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthuman ITEM ...
# Sorts the items of a list in human-readable ascending order
# @arguments:
# - ITEM: a list item
# @notes:
#   Human readable, e.g., 1K, 2M, 3G
function bb_util_list_sorthuman () {
    __bb_util_list_sort_opts=(-h)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthumandesc ITEM ...
# Sorts the items of a list in human-readable descending order
# @arguments:
# - ITEM: a list item
# @notes:
#   Human readable, e.g., 1K, 2M, 3G
function bb_util_list_sorthumandesc () {
    __bb_util_list_sort_opts=(-h -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# uniq ITEM ...
# Filters an unsorted list to include only unique items
# @arguments:
# - ITEM: a list item
function bb_util_list_uniq () {
    declare -A __bb_util_list_uniq_items=()
    local dedup=()
    local item
    for item in "$@"; do
        [[ ${__bb_util_list_uniq_items[$item]+set} ]] && continue
        __bb_util_list_uniq_items[$item]=1
        dedup+=("$item")
    done
    unset __bb_util_list_uniq_items
    echo "${dedup[*]}"
}

# uniqsorted ITEM ...
# Filters an sorted list to include only unique items
# @arguments:
# - ITEM: a list item
# @notes:
#   Faster than uniq, but requires the list to be pre-sorted
function bb_util_list_uniqsorted () {
    local dedup=("$1")
    local prev="$1"
    local item
    for item in "${@:2}"; do
        [[ $item == $prev ]] && continue
        prev="$item"
        dedup+=("$item")
    done
    echo "${dedup[*]}"
}
