_bb_on_first_load "bb_cli_color" || return

################################################################################
# Globals
################################################################################

declare -Ag __bb_cli_color_code=()
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
        return $__bb_false
    fi
    local fgcolor="${colorstr%%_on_*}"
    local colorcode
    local prefix=''
    if [[ "$colorstr" != "$fgcolor" ]]; then
        local bgcolor="${colorstr#*_on_}"
        colorcode=${__bb_cli_color_code["$bgcolor"]} 
        (( colorcode += 40 ))
        prefix+="\e[${colorcode}m"
    fi
    colorcode=${__bb_cli_color_code["$fgcolor"]} 
    (( colorcode += 30 ))
    prefix+="\e[${colorcode}m"
    printf '%b%s%b' "$prefix" "$text" "$__bb_cli_color_reset"
    return $__bb_true
}

# strip TEXT
bb_cli_color_colorstrip () {
    :
}
