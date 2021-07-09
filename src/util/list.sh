_bb_on_first_load "bb_util_list" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# join SEP ITEMS ...
function bb_util_list_join () {
    local IFS="$1"
    shift
    echo "$*"
}

# split LISTVAR SEP STR
function bb_util_list_split () {
    eval "$1=(${3//$2/ })"
}

# inlist TARGET LIST ...
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
function bb_util_list_push () {
    eval "$1=("\${$1[@]}" "$2")"
}

# pop LISTVAR
function bb_util_list_pop () {
    eval "unset $1[-1]"
}

# unshift LISTVAR ITEM
function bb_util_list_unshift () {
    eval "$1=("$2" "\${$1[@]}")"
}

# shift LISTVAR
function bb_util_list_shift () {
    eval "unset $1[0]"
}

function _bb_util_list_base_sort () {
    local IFS=$'\n'
    local sorted=( $(sort "${__bb_util_list_sort_opts[@]}" <<<"$*") )
    unset IFS
    echo "${sorted[*]}"
}

# sort ITEMS ...
# Lexicographical sort
function bb_util_list_sort () {
    _bb_util_list_base_sort "$@"
}

# sortdesc ITEMS ...
# Reverse lexicographical sort
function bb_util_list_sortdesc () {
    __bb_util_list_sort_opts=(-r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnums ITEMS ...
# Numeric sort
function bb_util_list_sortnums () {
    __bb_util_list_sort_opts=(-g)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sortnumsdesc ITEMS ...
# Numeric sort descending
function bb_util_list_sortnumsdesc () {
    __bb_util_list_sort_opts=(-g -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthuman ITEMS ...
# Human numeric sort
function bb_util_list_sorthuman () {
    __bb_util_list_sort_opts=(-h)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

# sorthumandesc ITEMS ...
# Human numeric sort descending
function bb_util_list_sorthumandesc () {
    __bb_util_list_sort_opts=(-h -r)
    _bb_util_list_base_sort "$@"
    unset __bb_util_list_sort_opts
}

