# @package: util/time
# Routines for common time and date operations

_bb_onfirstload "bb_util_time" || return

bb_load "util/math"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_now [-v VAR] [OFFSET ...]
# Returns a timestamp relative to the current time (in seconds after epoch)
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - OFFSET: {+,-}N{s,m,h,d,w} where N is an integer
# @returns: 1 if any offset is invalid, 0 otherwise
# @notes:
#   s: seconds
#   m: minutes
#   h: hours
#   d: days
#   w: weeks
function bb_now () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local result
    if [[ $# -eq 0 ]]; then
        printf -v result '%(%s)T' -1
        _bb_result "$result"
        return "$__bb_true"
    fi
    local ts="$(printf '%(%s)T' -1)"
    local offset
    for offset in "$@"; do
        local isadd=true
        case "${offset:0:1}" in
            +) ;;
            -) isadd=false ;;
            *) return "$__bb_false" ;;
        esac
        local unit=1
        case "${offset: -1}" in
            s) ;;
            m) unit=60 ;;
            h) unit=3600 ;;
            d) unit=86400 ;;
            w) unit=604800 ;;
            *) return "$__bb_false" ;;
        esac
        local val="${offset:1: -1}"
        bb_isint "$val" || return "$__bb_false"
        if $isadd; then
            (( ts += val * unit ))
        else
            (( ts -= val * unit ))
        fi
    done
    printf -v result '%(%s)T' "$ts"
    _bb_result "$result"
    return "$__bb_true"
}

# function: bb_timefmt [-v VAR] FORMAT [TIMESTAMP]
# Formats a timestamp into a desired date format
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - FORMAT: date format string, refer to man strftime
# - TIMESTAMP: epoch time, defaults to current time (now)
function bb_timefmt () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local result
    printf -v result "%($1)T" "${2:--1}"
    _bb_result "$result"
}
