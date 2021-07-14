# @package: util/string
# Routines for common string operations

_bb_on_first_load "bb_util_string" || return

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# snake2camel TEXT
# Converts text from snake to camel case
# @arguments:
# - TEXT: text in snake case
# @notes:
#   Leading underscores are preserved
function bb_util_string_snake2camel () {
    local str="$1"
    local i
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
    local i
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

# TODO: sentence and title case

# TODO: url encode/decode

