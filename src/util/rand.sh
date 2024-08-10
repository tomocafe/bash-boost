# @package: util/rand
# Routines for generating random sequences

_bb_onfirstload "bb_util_rand" || return

bb_load "util/list"

################################################################################
# Globals
################################################################################

__bb_util_rand_words=()
__bb_util_rand_wordct=0

################################################################################
# Functions
################################################################################

# function: bb_randint [-v VAR] MAX [MIN]
# Returns a random non-negative integer between MIN and MAX
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - MAX: the largest possible returned value
# - MIN: the smallest possible returned value (defaults to zero)
function bb_randint () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local max="$1"
    local min="${2:-0}"
    local result
    result=$(( (RANDOM % (max + 1 - min)) + min ))
    _bb_result "$result"
}

# function: bb_randstr [-v VAR] LENGTH [CHARSET]
# Returns a random string of the given length
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - LENGTH: length of the returned string
# - CHARSET: string with all possible characters to use (defaults to all alphanumeric characters)
function bb_randstr () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local len="$1"
    local charset="${2:-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789}"
    local -i N=${#charset}
    local result=""
    local -i i
    for (( i=0; i<len; i++ )); do
        result+="${charset:$(( RANDOM % N )):1}"
    done
    _bb_result "$result"
}

# function: bb_loadworddict [FILENAME]
# Loads a dictionary of words
# @arguments:
# - FILENAME: file containing words, one per line
# @notes:
#   The dictionary file should contain one word per line
function bb_loadworddict () {
    __bb_util_rand_words=()
    __bb_util_rand_wordct=0
    local line
    while read -r line; do
        [[ $line =~ ^[[:space:]]*$ ]] && continue
        __bb_util_rand_words+=("$line")
        let __bb_util_rand_wordct++
    done < "$1"
}

# function: bb_randwords [-v VAR] COUNT [SEP]
# Returns a string containing non-repeated random words from a loaded word dictionary
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - COUNT: number of returned words
# - SEP: separator to use between words (default is space)
# @notes:
#   You must load a word dictionary with bb_loadworddict before using this
function bb_randwords () {
    __bb_glopts_no_trailing_dash=1
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local count="$1"
    local sep="${2:- }"
    [[ $count -gt $__bb_util_rand_wordct ]] && return $__bb_false
    local used=()
    local result=""
    local -i i index
    for (( i=0; i<count; i++ )); do
        index="$(( RANDOM % __bb_util_rand_wordct ))"
        while bb_inlist "$index" "${used[@]}"; do
            index="$(( RANDOM % __bb_util_rand_wordct ))"
        done
        used+=("$index")
        result+="${result:+$sep}${__bb_util_rand_words[$index]}"
    done
    _bb_result "$result"
}
