# @package: util/list
# Routines for common list operations

_bb_onfirstload "bb_util_list" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_join [-v VAR] SEP ITEM ...
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

# function: bb_split [-V LISTVAR] SEP STR
# Splits a string into a list based on a separator
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - SEP: separator
# - STR: string to split
function bb_split () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local IFS=$1
    #local - # requires bash 4.4+ to keep shell settings local to function
    # Turn off globbing, local to this function
    local restore=""
    case $- in
        f) set -f; restore+="f" ;;
    esac
    local arr=()
    local token
    while IFS= read -r token; do
        # shellcheck disable=SC2206
        arr+=( $token ) # no quotes around $token -- important!
    done <<< "$2"
    # Restore globbing
    case $restore in
        f) set +f ;;
    esac
    IFS=' ' _bb_result "${arr[@]}"
}

# function: bb_inlist TARGET LIST ...
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
        [[ "$item" == "$target" ]] && return "$__bb_true"
    done
    return "$__bb_false"
}

# function: bb_push LISTVAR ITEM ...
# Pushes an item to a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - ITEM: item to push
function bb_push () {
    local v="$1"; shift
    eval "$v=("\${$v[@]}" "$@")"
}

# function: bb_pop LISTVAR
# Pops an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_pop () {
    eval "[[ \${#$1[@]} -gt 0 ]] && unset $1[\${#$1[@]}-1]" # negative array index requires bash 4.3+
}

# function: bb_unshift LISTVAR ITEM ...
# Unshifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - ITEM: item to unshift
function bb_unshift () {
    local v="$1"; shift
    eval "$v=("$@" "\${$v[@]}")"
}

# function: bb_shift LISTVAR
# Shifts an item from a list (stack)
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
function bb_shift () {
    eval "$1=(\"\${$1[@]:1}\")"
}

function _bb_util_list_base_sort () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local IFS=$'\n'
    local sorted=( $(sort "${__bb_util_list_sort_opts[@]}" <<<"$*") )
    unset IFS
    _bb_result "${sorted[@]}"
}

# function: bb_sort [-V LISTVAR] ITEM ...
# Sorts the items of a list in lexicographic ascending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sort () {
    _bb_util_list_base_sort "$@"
}

# function: bb_sortdesc [-V LISTVAR] ITEM ...
# Sorts the items of a list in lexicographic descending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortdesc () {
    __bb_util_list_sort_opts=(-r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# function: bb_sortnums [-V LISTVAR] ITEM ...
# Sorts the items of a list in numerical ascending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortnums () {
    __bb_util_list_sort_opts=(-g)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# function: bb_sortnumsdesc [-V LISTVAR] ITEM ...
# Sorts the items of a list in numerical descending order
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - ITEM: a list item
function bb_sortnumsdesc () {
    __bb_util_list_sort_opts=(-g -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# function: bb_sorthuman [-V LISTVAR] ITEM ...
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

# function: bb_sorthumandesc [-V LISTVAR] ITEM ...
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

# function: bb_uniq [-V LISTVAR] ITEM ...
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

# function: bb_uniqsorted [-V LISTVAR] ITEM ...
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
        [[ "$item" == "$prev" ]] && continue
        prev="$item"
        dedup+=("$item")
    done
    _bb_result "${dedup[@]}"
}

# function: bb_islist LISTVAR
# Checks if the variable with the given name is a list with >1 element
# @arguments:
# - LISTVAR: name of a variable
# @notes:
#   This will return false if the variable is declared as a list 
#   but only has 1 element. In that case, you can treat the variable
#   as a scalar anyway.
function bb_islist () {
    local listname="$1[@]"
    local list=("${!listname}")
    [[ ${#list[@]} -gt 1 ]]
}

# function: bb_rename ITEM ... -- NAME ...
# Assigns new variable names to items
# @arguments:
# - ITEM: a list item
# - NAME: a variable name
# @example:
# ```bash
# func() {
#   bb_rename "$@" -- first second
#   echo "The first argument is $first"
#   echo "The second argument is $second"
# }
# ```
function bb_rename () {
    local args=( "$@" )
    local -i j
    for (( j=0; j<${#args[@]}; j++ )); do
        [[ ${args[$j]} == '--' ]] && break
    done
    [[ $j -gt ${#args[@]} ]] && return
    local -i sep=$j
    local -i i
    for (( i=0, j++; i<sep && j<${#args[@]}; i++, j++ )); do
        printf -v "${args[$j]}" '%s' "${args[$i]}"
    done
}

# function: bb_unpack LISTVAR NAME ...
# Unpacks list items into named variables
# @arguments:
# - LISTVAR: name of the list variable (do not include $)
# - NAME: a variable name to hold a list element
function bb_unpack () {
    bb_rename "${!1[@]}" -- "${@:1}"
}
