# @package: util/string
# Routines for common string operations

_bb_onfirstload "bb_util_string" || return

bb_load "util/list"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_lstrip [-v VAR] TEXT
# Strips leading (left) whitespace from text
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to strip whitespace from
function bb_lstrip () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local resetopt=false
    if [[ ! -o extglob ]]; then
        shopt -s extglob
        resetopt=true
    fi
    _bb_result "${1##+([[:space:]])}"
    $resetopt && shopt -u extglob
}

# function: bb_rstrip [-v VAR] TEXT
# Strips trailing (right) whitespace from text
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to strip whitespace from
function bb_rstrip () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local resetopt=false
    if [[ ! -o extglob ]]; then
        shopt -s extglob
        resetopt=true
    fi
    _bb_result "${1%%+([[:space:]])}"
    $resetopt && shopt -u extglob
}

# function: bb_strip [-v VAR] TEXT
# Strips leading and trailing whitespace from text
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to strip whitespace from
function bb_strip () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local stripped="$1"
    bb_lstrip -v stripped "$stripped"
    bb_rstrip -v stripped "$stripped"
    _bb_result "$stripped"
}

# function: bb_ord [-v VAR] CHAR
# Converts character to its ASCII decimal code
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - CHAR: a single character 
function bb_ord () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local LC_CTYPE=C
    local ord 
    printf -v ord "%d" "'${1:0:1}" # note: intentional leading '
    _bb_result "$ord"
}

# function: bb_chr [-v VAR] CODE
# Converts ASCII decimal code to character
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - CODE: an integer ASCII character code
function bb_chr () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local oct chr
    printf -v oct "%03o" "$1"
    printf -v chr "\\$oct"
    _bb_result "$chr"
}

# function: bb_snake2camel [-v VAR] TEXT
# Converts text from snake to camel case
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text in snake case
# @notes:
#   Leading underscores are preserved
function bb_snake2camel () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local str="$1"
    local -i i
    local camel=""
    local start=false # preserve leading underscores
    local caps=false
    for (( i=0; i<${#str}; i++ )); do
        local char="${str:$i:1}"
        case "$char" in
            _)
                $start && caps=true || camel+="$char"
                ;;
            *)
                $caps && char="${char^^}"
                camel+="$char"
                start=true
                caps=false
                ;;
        esac
    done
    _bb_result "$camel"
}

# function: bb_camel2snake [-v VAR] TEXT
# Converts text from camel to snake case
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text in camel case
function bb_camel2snake () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local LC_ALL=C # otherwise lowercase a-z will match [A-Z] in case statement
    local str="$1"
    local -i i
    local snake=""
    for (( i=0; i<${#str}; i++ )); do
        local char="${str:$i:1}"
        [[ $i == 0 ]] && char="${char,,}" # force first character to be lowercase
        case "$char" in
            [A-Z])
                snake+="_${char,,}"
                ;;
            *)
                snake+="$char"
                ;;
        esac
    done
    _bb_result "$snake"
}

# function: bb_titlecase [-v VAR] TEXT
# Converts text into title case (every word capitalized)
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to transform
# @notes:
#   This does not check the content of the words itself and may not
#   respect grammatical rules, e.g. "And" will be capitalized
function bb_titlecase () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local str="$1"
    local -i i
    local title=""
    local caps=true
    for (( i=0; i<${#str}; i++ )); do
        local char="${str:$i:1}"
        case "$char" in
            [[:space:]])
                caps=true
                ;;
            *)
                $caps && char="${char^^}"
                caps=false
                ;;
        esac
        title+="$char"
    done
    _bb_result "$title"
}

# function: bb_sentcase [-v VAR] TEXT
# Converts text into sentence case (every first word capitalized)
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to transform
function bb_sentcase () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local str="$1"
    local -i i
    local sent=""
    local caps=true
    for (( i=0; i<${#str}; i++ )); do
        local char="${str:$i:1}"
        case "$char" in
            [.!?])
                caps=true
                ;;
            [[:space:]])
                ;;
            *)
                $caps && char="${char^^}"
                caps=false
                ;;
        esac
        sent+="$char"
    done
    _bb_result "$sent"
}

# function: bb_urlencode [-v VAR] TEXT
# Performs URL (percent) encoding on the given string
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to be encoded
function bb_urlencode () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local LC_ALL=C
    local text="$1"
    local encoded=""
    local -i i
    for (( i=0; i<${#text}; i++ )); do
        local char="${text:$i:1}"
        case "$char" in
            [[:alnum:].~_-]) printf -v char '%s' "$char" ;;
            *) printf -v char '%%%02X' "'$char" ;;
        esac
        encoded+="$char"
    done
    _bb_result "$encoded"
}

# function: bb_urldecode [-v VAR] TEXT
# Decodes URL-encoded text
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - TEXT: text to be decoded
# @returns: 1 if the input URL encoding is malformed, 0 otherwise
function bb_urldecode () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local LC_ALL=C
    local text="$1"
    local decoded=""
    local -i i
    for (( i=0; i<${#text}; i++ )); do
        local char="${text:$i:1}"
        case "$char" in
            %)
                char="${text:$i:3}"
                case "$char" in
                    %[[:xdigit:]][[:xdigit:]]) ;;
                    *) return "$__bb_false" ;; # malformed
                esac
                (( i+=2 ))
                printf -v char '%b' "\\x${char:1}"
                ;;
            +) printf -v char ' ' ;;
            *) printf -v char '%s' "$char" ;;
        esac
        decoded+="$char"
    done
    _bb_result "$decoded"
    return "$__bb_true"
}

# function: bb_repeatstr [-v VAR] NUM TEXT
# Repeat TEXT NUM times
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - NUM: repeat this many times (integer)
# - TEXT: text to repeat
function bb_repeatstr () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    local rep
    # shellcheck disable=SC2183
    printf -v rep '%*s' "$1"
    printf -v rep "${rep// /$2}"
    _bb_result "$rep"
}

# function: bb_cmpversion VER1 VER2 [DELIM]
# Checks if VER1 is greater than or equal to VER2
# @arguments:
# - VER1: a version string (containing only numerals and delimeters)
# - VER2: another version string, usually a reference point
# - DELIM: character(s) to delimit fields in the version string (default: .-_)
# @returns: 0 if VER1 greater or equal to VER2, 1 otherwise
# @notes:
#   Numeric comparison is used, so alphabetical characters are not supported
function bb_cmpversion () {
    local lhs rhs
    bb_split -V lhs ".-_" "$1"
    bb_split -V rhs ".-_" "$2"
    local l r
    for l in "${lhs[@]}"; do
        [[ ${#rhs[@]} -gt 0 ]] || break
        r="${rhs[0]}"
        [[ ${l##0*} -ge ${r##0*} ]] || return "$__bb_false"
        bb_shift rhs
    done
    [[ ${#rhs[@]} -eq 0 ]]
}
