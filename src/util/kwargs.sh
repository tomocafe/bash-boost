__bb_this="bb_util_kwargs"
bb_on_first_load "$__bb_this" || return

################################################################################
# Globals
################################################################################

declare -Ag _bb_util_kwargs_dict=()

################################################################################
# Functions
################################################################################

# kwparse KEY=VAL ...
bb_util_kwargs_kwparse () {
    local pair
    for pair in "$@"; do
        local key="${pair%%=*}"
        local val="${pair#*=}"
        [[ "$key" == "$val" ]] && return $_bb_false
        _bb_util_kwargs_dict["$key"]="$val"
    done
    return $_bb_true
}

# kwget KEY
bb_util_kwargs_kwget () {
    echo -n "${_bb_util_kwargs_dict["$1"]}"
}
