_bb_on_first_load "bb_util_kwargs" || return

################################################################################
# Globals
################################################################################

declare -Ag __bb_util_kwargs_dict=()

################################################################################
# Functions
################################################################################

# kwparse KEY=VAL ...
function bb_util_kwargs_kwparse () {
    local pair
    for pair in "$@"; do
        local key="${pair%%=*}"
        local val="${pair#*=}"
        [[ "$key" == "$val" ]] && return $__bb_false
        __bb_util_kwargs_dict["$key"]="$val"
    done
    return $__bb_true
}

# kwget KEY
function bb_util_kwargs_kwget () {
    echo -n "${__bb_util_kwargs_dict["$1"]}"
}

# kwclear
function bb_util_kwargs_kwclear () {
    __bb_util_kwargs_dict=()
}
