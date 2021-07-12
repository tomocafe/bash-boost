_bb_on_first_load "bb_util_kwargs" || return

################################################################################
# Globals
################################################################################

declare -Ag __bb_util_kwargs_dict=()

################################################################################
# Functions
################################################################################

# kwparse KEY=VAL ...
# Parses a list of KEY=VAL pairs and stores them into a global dictionary
# @arguments:
# - KEY=VAL: a key-value pair separated by =
# @notes:
#   kwparse stores key-value pairs into a single, global dictionary
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
# Gets the value associated with a key stored with kwparse
# @arguments:
# - KEY: the key
function bb_util_kwargs_kwget () {
    echo -n "${__bb_util_kwargs_dict["$1"]}"
}

# kwclear
# Clears the global dictionary
function bb_util_kwargs_kwclear () {
    __bb_util_kwargs_dict=()
}
