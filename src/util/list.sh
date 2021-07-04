_bb_on_first_load "bb_util_list" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# join SEP ITEMS ...
bb_util_list_join () {
    local IFS="$1"
    shift
    echo "$*"
}

# split SEP STR
bb_util_list_split () {
    :
}

# inlist TARGET LIST ...
bb_util_list_inlist () {
    local target="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$target" ]] && return $__bb_true
    done
    return $__bb_false
}
