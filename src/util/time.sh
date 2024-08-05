# @package: util/time
# Routines for common time and date operations
# @example:
# ```bash
# bb_timefmt "%F %T" # e.g., 2022-11-20 16:53:30
# bb_timefmt "%F %T" $(bb_now +1h) # one hour from now
# bb_timefmt "%F %T" $(bb_now ^h)  # end of the hour
# bb_timefmt "%F %T" $(bb_now +1d) # one day from now
# bb_timefmt "%F %T" $(bb_now ^d)  # end of the day
# bb_timefmt "%F %T" $(bb_now +2w ^d) # after two weeks, at end of day
# ```

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
# - OFFSET: {+,-}N{s,m,h,d,w}[^] where N is an integer
# @returns: 1 if any offset is invalid, 0 otherwise
# @notes:
#   s: seconds
#   m: minutes
#   h: hours
#   d: days
#   w: weeks
#   Optional: trailing ^ rounds up; ^d is short for +0d^
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
        local round=false
        case "${offset:0:1}" in
            +) ;;
            -) isadd=false ;;
            ^) round=true ;;
            *) return "$__bb_false" ;;
        esac
        if [[ "${offset: -1}" == "^" ]]; then
            round=true
            offset="${offset:0: -1}"
        fi
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
        [[ $val == "" ]] && val=0
        bb_isint "$val" || return "$__bb_false"
        if $isadd; then
            (( ts += val * unit ))
        else
            (( ts -= val * unit ))
        fi
        if $round; then
            (( ts = ((ts / unit) + 1) * unit ))
            if [[ $unit -gt 3600 ]]; then
                # Need to consider timezone if rounding to start of day/week
                local tz tzoff
                printf -v tz '%(%z)T' # e.g., -0800, +0530
                [[ $tz =~ [+-][01][0-9][03]0 ]] || return "$__bb_false"
                (( tzoff = 10#${tz:3:2}*60 + 10#${tz:1:2}*3600 )) # specify base 10 due to leading zero
                case "${tz:0:1}" in
                    +) (( ts = ts - tzoff )) ;;
                    -) (( ts = ts + tzoff - 86400 )) ;;
                esac
            fi
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

# function: bb_timedeltafmt [-v VAR] FORMAT TIME1 [TIME2]
# Formats a time delta into a desired format
# @arguments:
# - VAR:
# - FORMAT:
# - TIME1: if TIME1 not specified, this is interpreted as a duration in seconds
# - TIME2: if specified, TIME1 is the end timestamp and TIME2 is the start timestamp
# @notes:
#   Capital letters D, H, M, S represent the partial value
#   Lowercase letters d, h, m, s represent the total value
# @example:
# ```bash
# bb_now -v start
# sleep 120s
# bb_now -v end
# bb_timedeltafmt -v elapsed "%H:%M:%S" end start
# bb_timedeltafmt -v total_seconds "%s" end start
# echo "elapsed time $elapsed, $total_seconds total seconds"
# # above should print "elapsed time 00:02:00, 120 total seconds"
# ```
function bb_timedeltafmt () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local result="$1"
    local delta="$2"
    [[ $# -ge 3 ]] && delta=$(( delta - $3 ))
    local D H M S d h m s
    s="$delta"
    m=$(( s / 60 ))
    h=$(( m / 60 ))
    d=$(( h / 24 ))
    S=$(( s % 60 ))
    M=$(( m % 60 ))
    H=$(( h % 24 ))
    D="$d"

    printf -v S "%02d" "$S"
    printf -v M "%02d" "$M"
    printf -v H "%02d" "$H"
    printf -v D "%02d" "$D"

    result="${result//%S/$S}"
    result="${result//%M/$M}"
    result="${result//%H/$H}"
    result="${result//%D/$D}"
    result="${result//%s/$s}"
    result="${result//%m/$m}"
    result="${result//%h/$h}"
    result="${result//%d/$d}"

    _bb_result "$result"
}
