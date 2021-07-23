# @package: util/string
# Routines for common string operations

_bb_onfirstload "bb_util_string" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# lstrip TEXT
# Strips leading (left) whitespace from text
# @arguments:
# - TEXT: text to strip whitespace from
function bb_util_string_lstrip () {
    local resetopt=false
    if [[ ! -o extglob ]]; then
        shopt -s extglob
        resetopt=true
    fi
    echo -n "${1##+([[:space:]])}"
    $resetopt && shopt -u extglob
}

# rstrip TEXT
# Strips trailing (right) whitespace from text
# @arguments:
# - TEXT: text to strip whitespace from
function bb_util_string_rstrip () {
    local resetopt=false
    if [[ ! -o extglob ]]; then
        shopt -s extglob
        resetopt=true
    fi
    echo -n "${1%%+([[:space:]])}"
    $resetopt && shopt -u extglob
}

# strip TEXT
# Strips leading and trailing whitespace from text
# @arguments:
# - TEXT: text to strip whitespace from
function bb_util_string_strip () {
    echo -n "$(bb_util_string_lstrip "$(bb_util_string_rstrip "$1")")"
}

# snake2camel TEXT
# Converts text from snake to camel case
# @arguments:
# - TEXT: text in snake case
# @notes:
#   Leading underscores are preserved
function bb_util_string_snake2camel () {
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
    echo -n "$camel"
}

# camel2snake TEXT
# Converts text from camel to snake case
# @arguments:
# - TEXT: text in camel case
function bb_util_string_camel2snake () {
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
    echo -n "$snake"
}

# titlecase TEXT
# Converts text into title case (every word capitalized)
# @arguments:
# - TEXT: text to transform
# @notes:
#   This does not check the content of the words itself and may not
#   respect grammatical rules, e.g. "And" will be capitalized
function bb_util_string_titlecase () {
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
    echo -n "$title"
}

# sentcase TEXT
# Converts text into sentence case (every first word capitalized)
# @arguments:
# - TEXT: text to transform
function bb_util_string_sentcase () {
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
    echo -n "$sent"
}

# urlencode TEXT
# Performs URL (percent) encoding on the given string
# @arguments:
# - TEXT: text to be encoded
function bb_util_string_urlencode () {
    local LC_ALL=C
    local text="$1"
    local -i i
    for (( i=0; i<${#text}; i++ )); do
        local char="${text:$i:1}"
        case "$char" in
            [[:alnum:].~_-]) printf '%s' "$char" ;;
            *) printf '%%%02X' "'$char" ;;
        esac
    done
}

# urldecode TEXT
# Decodes URL-encoded text
# @arguments:
# - TEXT: text to be decoded
# @returns: 1 if the input URL encoding is malformed, 0 otherwise
function bb_util_string_urldecode () {
    local LC_ALL=C
    local text="$1"
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
                printf '%b' "\\x${char:1}"
                ;;
            *) printf '%s' "$char" ;;
        esac
    done
    return $__bb_true
}
