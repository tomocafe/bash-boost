# @package: cli/progress
# Text-based progress bar
# @example:
# ```bash
# for pct in {0..100}; do sleep 0.1s; bb_progressbar $pct "Downloading"; done; echo
# for pct in {0..100}; do sleep 0.1s; bb_progressbar $pct "Unpacking"; done; echo
# for pct in {0..100}; do sleep 0.1s; bb_progressbar $pct "Installing"; done; echo
# ```

_bb_onfirstload "bb_cli_progress" || return

bb_load "util/math"
bb_load "util/string"

################################################################################
# Globals
################################################################################



################################################################################
# Functions
################################################################################

# function: bb_progressbar VALUE TEXT
# Prints/updates a progress bar
# @arguments:
# - VALUE: integer from 0 to 100; 100 meaning complete
# - TEXT: optional text to be displayed
# @notes:
#   Customize the start, end, and fill characters by setting environment 
#   variables BB_PROGRESS_START, BB_PROGRESS_END, and BB_PROGRESS_FILL.
#   By default these are set to [, ], and .
function bb_progressbar () {
    local val="${1:-0}"
    local text="$2"
    # Defaults
    local start="${BB_PROGRESS_START:-[}"
    local end="${BB_PROGRESS_END:-]}"
    local fillchar="${BB_PROGRESS_FILL:-.}"
    # Get number of columns
    local resetopt=false
    if [[ ! -o checkwinsize ]]; then
        shopt -s checkwinsize
        resetopt=true
    fi
    local cols=${COLUMNS?set checkwinsize}
    # Ensure val is an int between 0 and 100
    bb_isint "$val" || val=0
    bb_max -v $val $val 0
    bb_min -v $val $val 100
    # Truncate text if it doesn't fit
    local barspace=$(( cols - 5 - ${#start} - ${#end} ))
    local maxtextsz=$(( barspace - 1 )) # for space after text
    text="${text:0:$maxtextsz}"
    # Calculate bar size
    fillct=$(( val * barspace / 100 ))
    local nonblankct
    bb_max -v nonblankct "$(( ${#text} + 1 ))" $fillct
    blankct=$(( barspace - nonblankct ))
    fillct=$(( fillct - ${#text} - 1 )) # text is part of the fill
    bb_max -v fillct $fillct 0
    # Build and output string
    local fill blank
    bb_repeatstr -v fill $fillct "${fillchar:0:1}"
    bb_repeatstr -v blank $blankct " "
    printf -- '\r%s%s %s%s %3d%%%s' "$start" "$text" "$fill" "$blank" "$val" "$end"
    # Reset shell opts if altered
    $resetopt && shopt -u checkwinsize
}
