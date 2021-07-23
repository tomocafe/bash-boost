# @package: util/math
# Routines for common math operations

_bb_onfirstload "bb_util_math" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# sum NUM ...
# Returns the sum of the given numbers
# @arguments:
# - NUM: a valid number
function bb_util_math_sum () {
    local sum=0
    local n
    for n in "$@"; do
        (( sum += n ))
    done
    echo -n "$sum"
}

# min NUM ...
# Returns the minimum of the given numbers
# @arguments:
# - NUM: a valid number
function bb_util_math_min () {
    local min="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -lt $min ]] && min="$n"
    done
    echo -n "$min"
}

# max NUM ...
# Returns the maximum of the given numbers
# @arguments:
# - NUM: a valid number
function bb_util_math_max () {
    local max="$1"
    local n
    for n in "${@:2}"; do
        [[ $n -gt $max ]] && max="$n"
    done
    echo -n "$max"
}

# abs NUM
# Returns the absolute value of a given number
# @arguments:
# - NUM: a valid number
function bb_util_math_abs () {
    local abs="$1"
    [[ $abs -lt 0 ]] && abs="${abs#-}"
    echo -n "$abs"
}

# isint NUM ...
# Checks if all the given numbers are valid integers
# @arguments:
# - NUM: a number to check
# @returns: 0 if all arguments are integers, 1 otherwise
function bb_util_math_isint () {
    local re='^-*[0-9]+$'
    local n
    for n in "$@"; do
        [[ $n =~ $re ]] || return $__bb_false
    done
    return $__bb_true
}

# hex2dec NUM ...
# Converts numbers from hexademical (base 16) to decimal (base 10)
# @arguments:
# - NUM: a number to convert
# @returns: 1 if any number is invalid hexadecimal, 0 otherwise
function bb_util_math_hex2dec () {
    local n
    local res=()
    for n in "$@"; do
        [[ $n == '0' ]] && { res+=("$n"); continue; }
        (( n=16#$n )) 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    echo -n "${res[*]}"
    return $__bb_true
}

# dec2hex NUM ...
# Converts numbers from decimal (base 10) to hexademical (base 16)
# @arguments:
# - NUM: a number to convert
# @returns: 1 if any number is invalid decimal, 0 otherwise
function bb_util_math_dec2hex () {
    local n
    local res=()
    for n in "$@"; do
        printf -v n '%x' "$n" 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    echo -n "${res[*]}"
    return $__bb_true
}

# oct2dec NUM ...
# Converts numbers from octal (base 8) to decimal (base 10)
# @arguments:
# - NUM: a number to convert
# @returns: 1 if any number is invalid octal, 0 otherwise
function bb_util_math_oct2dec () {
    local n
    local res=()
    for n in "$@"; do
        [[ $n == '0' ]] && { res+=("$n"); continue; }
        (( n=8#$n )) 2>/dev/null || return $__bb_false
        res+=( "$n" )
    done
    echo -n "${res[*]}"
    return $__bb_true
}

# dec2oct NUM ...
# Converts numbers from decimal (base 10) to octal (base 8)
# @arguments:
# - NUM: a number to convert
# @returns: 1 if any number is invalid decimal, 0 otherwise
function bb_util_math_dec2oct () {
    local n
    local res=()
    for n in "$@"; do
        printf -v n '%o' "$n" || return $__bb_false
        res+=( "$n" )
    done
    echo -n "${res[*]}"
    return $__bb_true
}
