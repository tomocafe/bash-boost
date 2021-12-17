# @package: util/math
# Routines for common math operations

_bb_onfirstload "bb_util_math" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# bb_sum [-v VAR] NUM ...
# Returns the sum of the given numbers
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - NUM: a valid number
function bb_sum () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local sum=0
    local n
    for n in "$@"; do
        (( sum += n ))
    done
    _bb_result "$sum"
}

# bb_min [-v VAR] NUM ...
# Returns the minimum of the given numbers
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - NUM: a valid number
function bb_min () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local min="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -lt $min ]] && min="$n"
    done
    _bb_result "$min"
}

# bb_max [-v VAR] NUM ...
# Returns the maximum of the given numbers
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - NUM: a valid number
function bb_max () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local max="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -gt $max ]] && max="$n"
    done
    _bb_result "$max"
}

# bb_abs [-v VAR] NUM
# Returns the absolute value of a given number
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - NUM: a valid number
function bb_abs () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local abs="$1"
    [[ $abs -lt 0 ]] && abs="${abs#-}"
    _bb_result "$abs"
}

# bb_isint NUM ...
# Checks if all the given numbers are valid integers
# @arguments:
# - NUM: a number to check
# @returns: 0 if all arguments are integers, 1 otherwise
function bb_isint () {
    local re='^-*[0-9]+$'
    local n
    for n in "$@"; do
        [[ $n =~ $re ]] || return $__bb_false
    done
    return $__bb_true
}

# bb_hex2dec [-V LISTVAR] NUM ...
# Converts numbers from hexademical (base 16) to decimal (base 10)
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - NUM: a number to convert
# @returns: 1 if any number is invalid hexadecimal, 0 otherwise
function bb_hex2dec () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local n
    local res=()
    for n in "$@"; do
        [[ $n == '0' ]] && { res+=("$n"); continue; }
        (( n=16#$n )) 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    _bb_result "${res[@]}"
    return $__bb_true
}

# bb_dec2hex [-V LISTVAR] NUM ...
# Converts numbers from decimal (base 10) to hexademical (base 16)
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - NUM: a number to convert
# @returns: 1 if any number is invalid decimal, 0 otherwise
function bb_dec2hex () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local n
    local res=()
    for n in "$@"; do
        printf -v n '%x' "$n" 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    _bb_result "${res[@]}"
    return $__bb_true
}

# bb_oct2dec [-V LISTVAR] NUM ...
# Converts numbers from octal (base 8) to decimal (base 10)
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - NUM: a number to convert
# @returns: 1 if any number is invalid octal, 0 otherwise
function bb_oct2dec () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local n
    local res=()
    for n in "$@"; do
        [[ $n == '0' ]] && { res+=("$n"); continue; }
        (( n=8#$n )) 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    _bb_result "${res[@]}"
    return $__bb_true
}

# bb_dec2oct [-V LISTVAR] NUM ...
# Converts numbers from decimal (base 10) to octal (base 8)
# @arguments:
# - LISTVAR: list variable to store result (if not given, prints to stdout)
# - NUM: a number to convert
# @returns: 1 if any number is invalid decimal, 0 otherwise
function bb_dec2oct () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local n
    local res=()
    for n in "$@"; do
        printf -v n '%o' "$n" || return $__bb_false
        res+=( "$n" )
    done
    _bb_result "${res[@]}"
    return $__bb_true
}
