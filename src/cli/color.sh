__bb_this="bb_cli_color"
bb_on_first_load "$__bb_this" || return

################################################################################
# Globals
################################################################################

declare -Ag _bb_cli_color_code=()
_bb_cli_color_code['black']=0
_bb_cli_color_code['red']=1
_bb_cli_color_code['green']=2
_bb_cli_color_code['yellow']=3
_bb_cli_color_code['blue']=4
_bb_cli_color_code['magenta']=5
_bb_cli_color_code['cyan']=6
_bb_cli_color_code['bright_gray']=7
_bb_cli_color_code['dark_white']=7
_bb_cli_color_code['gray']=60
_bb_cli_color_code['bright_black']=60
_bb_cli_color_code['bright_red']=61
_bb_cli_color_code['bright_green']=62
_bb_cli_color_code['bright_yellow']=63
_bb_cli_color_code['bright_blue']=64
_bb_cli_color_code['bright_magenta']=65
_bb_cli_color_code['bright_cyan']=66
_bb_cli_color_code['bright_white']=67
_bb_cli_color_code['white']=67

_bb_cli_color_reset='\e[0m'

################################################################################
# Functions
################################################################################

# COLORSTR = FGCOLOR[_on_[BGCOLOR]]
# e.g. red, bright_red, white_on_red, black_on_cyan

# colorize COLORSTR TEXT
# This does not print a new line at the end of TEXT
bb_cli_color_colorize () {
    local colorstr="$1"
    local text="$2"
    # Check if this is a terminal, return otherwise
    if ! [[ -t 1 ]]; then
        printf "$text"
        return $_bb_false
    fi
    local fgcolor="${colorstr%%_on_*}"
    local colorcode
    local prefix=''
    if [[ "$colorstr" != "$fgcolor" ]]; then
        local bgcolor="${colorstr#*_on_}"
        colorcode=${_bb_cli_color_code["$bgcolor"]} 
        (( colorcode += 40 ))
        prefix+="\e[${colorcode}m"
    fi
    colorcode=${_bb_cli_color_code["$fgcolor"]} 
    (( colorcode += 30 ))
    prefix+="\e[${colorcode}m"
    printf '%b%s%b' "$prefix" "$text" "$_bb_cli_color_reset"
    return $_bb_true
}

# strip TEXT
bb_cli_color_colorstrip () {
    :
}
