# @package: util/kwargs
# Routines for parsing keyword arg strings

_bb_onfirstload "bb_util_kwargs" || return

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
function bb_kwparse () {
    local pair
    for pair in "$@"; do
        local key="${pair%%=*}"
        local val="${pair#*=}"
        [[ "$key" == "$val" ]] && return $__bb_false
        __bb_util_kwargs_dict["$key"]="$val"
    done
    return $__bb_true
}

# kwget [-v VAR] KEY
# Gets the value associated with a key stored with kwparse
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - KEY: the key
function bb_kwget () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    _bb_result "${__bb_util_kwargs_dict["$1"]}"
}

# kwclear
# Clears the global dictionary
function bb_kwclear () {
    __bb_util_kwargs_dict=()
}
