# @package: cli/color
# Routines for printing text in color using ANSI escape codes

_bb_onfirstload "bb_cli_color" || return

################################################################################
# Globals
################################################################################

declare -Ag __bb_cli_color_code
__bb_cli_color_code['black']=0
__bb_cli_color_code['red']=1
__bb_cli_color_code['green']=2
__bb_cli_color_code['yellow']=3
__bb_cli_color_code['blue']=4
__bb_cli_color_code['magenta']=5
__bb_cli_color_code['cyan']=6
__bb_cli_color_code['bright_gray']=7
__bb_cli_color_code['dark_white']=7
__bb_cli_color_code['gray']=60
__bb_cli_color_code['bright_black']=60
__bb_cli_color_code['bright_red']=61
__bb_cli_color_code['bright_green']=62
__bb_cli_color_code['bright_yellow']=63
__bb_cli_color_code['bright_blue']=64
__bb_cli_color_code['bright_magenta']=65
__bb_cli_color_code['bright_cyan']=66
__bb_cli_color_code['bright_white']=67
__bb_cli_color_code['white']=67

__bb_cli_color_reset='\e[0m'
__bb_cli_color_fsep=$'\037' # unit separator char

################################################################################
# Functions
################################################################################

# bb_colorize COLORSTR TEXT
# Prints the given text in color if outputting to a terminal
# @arguments:
# - COLORSTR: FGCOLOR[_on_[BGCOLOR]] (e.g. red, bright_red, white_on_blue)
# - TEXT: text to be printed in color
# @returns: 0 if text was printed in color, 1 otherwise
# @notes:
#   Supported colors:
#   - black
#   - red
#   - green
#   - yellow
#   - blue
#   - magenta
#   - cyan
#   - bright_gray (dark_white)
#   - gray (bright_black)
#   - bright_red
#   - bright_green
#   - bright_yellow
#   - bright_blue
#   - bright_magenta
#   - bright_cyan
#   - white (bright_white)
#
#   This does not print a new line at the end of TEXT
function bb_colorize () {
    local colorstr="$1"
    local text="$2"
    local rc=$__bb_true
    # Check if this is a terminal, return otherwise
    if ! [[ -t 1 ]] && [[ -z "${__bb_cli_color_rawcolor+set}" ]]; then
        printf -- "$text"
        return $__bb_false
    fi
    local fgcolor="${colorstr%%_on_*}"
    local colorcode
    local prefix=''
    if [[ "$colorstr" != "$fgcolor" ]]; then
        local bgcolor="${colorstr#*_on_}"
        colorcode=${__bb_cli_color_code["$bgcolor"]}
        if [[ -z "$colorcode" ]]; then
            printf -- "$text"
            return $__bb_false
        fi
        (( colorcode += 40 ))
        prefix+="${__bb_cli_color_escapeprompt+\[}\e[${colorcode}m${__bb_cli_color_escapeprompt+\]}"
    fi
    colorcode=${__bb_cli_color_code["$fgcolor"]}
    if [[ -z "$colorcode" ]]; then
        printf -- "$text"
        return $__bb_false
    fi
    (( colorcode += 30 ))
    prefix+="${__bb_cli_color_escapeprompt+\[}\e[${colorcode}m${__bb_cli_color_escapeprompt+\]}"
    local reset="${__bb_cli_color_escapeprompt+\[}$__bb_cli_color_reset${__bb_cli_color_escapeprompt+\]}"
    # Surround all non-text escape sequences with unit separator so they can be easily trimmed later
    prefix="${__bb_cli_color_fsep}${prefix}${__bb_cli_color_fsep}"
    reset="${__bb_cli_color_fsep}${reset}${__bb_cli_color_fsep}"
    printf -- '%b%s%b' "$prefix" "$text" "$reset"
    return $__bb_true
}

# bb_rawcolor COLORSTR TEXT
# Like colorize but always uses prints in color
# @arguments:
# - COLORSTR: FGCOLOR[_on_[BGCOLOR]] (e.g. red, bright_red, white_on_blue)
# - TEXT: text to be printed in color
# @notes:
#   Use this instead of colorize if you need to still print in color even if
#   not connected to a terminal, e.g. when saving the output to a variable.
#   See colorize for supported colors
function bb_rawcolor () {
    __bb_cli_color_rawcolor=1
    bb_colorize "$@"
    unset __bb_cli_color_rawcolor
}

# bb_colorstrip TEXT
# Strips ANSI color codes from text colorized by colorize (or rawcolor)
# @arguments:
# - TEXT: text possibly with color escape codes to be removed
# @notes:
#   This will only work on text generated by colorize and variants,
#   not for any generic string with ANSI escape codes. It relies on the
#   invisible unit (field) separator character to mark the boundaries
#   between control sequences and real text
function bb_colorstrip () {
    local stripped=""
    local -i i
    local -i sepct=0
    for (( i=0; i<${#1}; i++)); do
        local char="${1:$i:1}"
        if [[ $char == $__bb_cli_color_fsep ]]; then
            let sepct++
        elif [[ $(( sepct % 2 )) -eq 0 ]]; then
            stripped+="$char"
        fi
    done
    printf -- "%s" "$stripped"
}

