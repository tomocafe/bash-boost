_bb_on_first_load "bb_util_math" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# sum NUMS ...
bb_util_math_sum () {
    local sum=0
    local n
    for n in "$@"; do
        (( sum += n ))
    done
    echo "$sum"
}

# min NUMS ...
bb_util_math_min () {
    local min="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -lt $min ]] && min="$n"
    done
    echo "$min"
}

# max NUMS ...
bb_util_math_max () {
    local max="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -gt $max ]] && max="$n"
    done
    echo "$max"
}

# isint NUMS ...
bb_util_math_isint () {
    local re='^-*[0-9]+$'
    local n
    for n in "$@"; do
        [[ $n =~ $re ]] || return $__bb_false
    done
    return $__bb_true
}
