# @package: util/string
# Routines for common string operations

_bb_onfirstload "bb_util_string" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# bb_lstrip [-v VAR] TEXT
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

# bb_rstrip [-v VAR] TEXT
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

# bb_strip [-v VAR] TEXT
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

# bb_snake2camel [-v VAR] TEXT
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

# bb_camel2snake [-v VAR] TEXT
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

# bb_titlecase [-v VAR] TEXT
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

# bb_sentcase [-v VAR] TEXT
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

# bb_urlencode [-v VAR] TEXT
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

# bb_urldecode [-v VAR] TEXT
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
                    *) return $__bb_false ;; # malformed
                esac
                let i+=2
                printf -v char '%b' "\\x${char:1}"
                ;;
            +) printf -v char ' ' ;;
            *) printf -v char '%s' "$char" ;;
        esac
        decoded+="$char"
    done
    _bb_result "$decoded"
    return $__bb_true
}
