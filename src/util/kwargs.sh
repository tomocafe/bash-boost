# @package: util/kwargs
# Routines for parsing keyword arg strings

_bb_onfirstload "bb_util_kwargs" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# bb_kwparse MAP KEY=VAL ... ARGS ...
# Parses a list of KEY=VAL pairs and stores them into a dictionary
# @arguments:
# - MAP: name of an associative array to be created
# - KEY=VAL: a key-value pair separated by =
# - ARGS: other arguments not in KEY=VAL format are ignored
# @notes:
#   Get non-keyword arguments with ${BB_OTHERARGS[@]}
function bb_kwparse () {
    [[ $# -gt 0 ]] || return
    local mapname="$1"; shift
    eval "declare -Ag $mapname"
    local pair
    BB_OTHERARGS=()
    for pair in "$@"; do
        if [[ $pair != *=* ]]; then
            BB_OTHERARGS+=("$pair")
            continue
        fi
        local key="${pair%%=*}"
        local val="${pair#*=}"
        eval "${mapname}["$key"]="$val""
    done
}
