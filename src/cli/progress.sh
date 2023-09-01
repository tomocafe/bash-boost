# @package: cli/progress
# Text-based progress bar and checkpoint pass/fail status line generator
# @example:
# ```bash
# ping -c 1 8.8.8.8 &>/dev/null; bb_checkpoint "Pinging DNS"
# for pct in {0..100}; do sleep 0.1s; bb_progressbar $pct "Downloading"; done; echo
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
    bb_max -v val $val 0
    bb_min -v val $val 100
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

# function: bb_checkpoint TEXT [RESULT]
# Prints a status line with pass/fail result based on RESULT
# @arguments:
# - TEXT: text to be displayed
# - RESULT: 0 for pass, nonzero for fail; if not given, infers from $?
# @notes:
#   Customize the fill character and pass/fail text by setting environment 
#   variables BB_CHECKPOINT_FILL, BB_CHECKPOINT_PASS, and BB_CHECKPOINT_FAIL.
#   By default these are set to space, OK, and FAIL.
function bb_checkpoint () {
    local result="${2:-$?}" # keep this first
    local text="$1"
    # Defaults
    local pass="${BB_CHECKPOINT_PASS:-OK}"
    local fail="${BB_CHECKPOINT_FAIL:-FAIL}"
    local fillchar="${BB_CHECKPOINT_FILL:- }"
    local start="${BB_CHECKPOINT_START:-[}"
    local end="${BB_CHECKPOINT_END:-]}"
    local statuswidth
    bb_max -v statuswidth "${#pass}" "${#fail}"
    local color
    if [[ $result -eq 0 ]]; then
        result="$pass"
        color='bright_green'
    else
        result="$fail"
        color='bright_red'
    fi
    # Get number of columns
    local resetopt=false
    if [[ ! -o checkwinsize ]]; then
        shopt -s checkwinsize
        resetopt=true
    fi
    local cols=${COLUMNS?set checkwinsize}
    # Build string
    local fillct=$((cols - ${#text} - 2 - ${#start} - ${#end} - $statuswidth))
    local fill status
    bb_repeatstr -v fill $fillct "${fillchar:0:1}"
    bb_centerstr -v status $statuswidth "$result"
    printf '%s %s %s' "$text" "$fill" "$start"
    bb_colorize "$color" "$status"
    printf '%s\n' "$end"
    # Reset shell opts if altered
    $resetopt && shopt -u checkwinsize
}
