#!/usr/bin/env bash

shopt -s checkwinsize

source ../../latest/bash-boost.sh

bb_load \
    cli/arg     \
    cli/color   \
    util/list   \
    util/string \
    util/time   \
    util/env

# parse arguments
bb_addopt H:hours   "number of hours"   0
bb_addopt M:mins    "number of minutes" 0
bb_addopt S:secs    "number of seconds" 0
bb_addopt y:yellow  "color display yellow at this second value" 60
bb_addopt r:red     "color display red at this second value"    10
bb_addopt F:timefmt "time format (default: %H:%M:%S)" "%H:%M:%S"
bb_setpositional "TIMESTR" "time string in the form [H:[M:]]S"
bb_setprog
bb_parseargs "$@"
set -- "${BB_POSARGS[@]}" # $@ now only contains the positional arguments

if [[ $# -gt 0 ]]; then
    # have a positional argument, it should be a time string
    # split into list called hms
    bb_split -V hms : "$1"
    # strip leading zeros from list elements
    zerostrip () { echo "${1#0}"; }
    bb_map hms zerostrip
    # convert to total seconds
    countdown=0
    secfactor=(1 60 3600)
    while [[ ${#hms[@]} -gt 0 ]]; do
        (( countdown += ${hms[-1]} * ${secfactor[0]} ))
        bb_pop hms
        bb_shift secfactor
    done
else
    bb_getopt -v h hours
    bb_getopt -v m mins
    bb_getopt -v s secs
    countdown=$(( h * 3600 + m * 60 + s ))
fi

bb_getopt -v turn_yellow yellow
bb_getopt -v turn_red red
bb_getopt -v timefmt timefmt

update_display () {
    # choose color
    local color="green"
    if [[ $countdown -le $turn_red ]]; then
        color="red"
    elif [[ $countdown -le $turn_yellow ]]; then
        color="yellow"
    fi
    # build time string
    local timestr
    bb_timedeltafmt -v timestr "$timefmt" $countdown
    # build line
    local line
    bb_centerstr -v line $COLUMNS "$(bb_rawcolor $color "$timestr")"
    # print line with leading carriage return to overwrite the previous line
    printf "\r%s" "$line"
}

# update display whenever the terminal width is changed
trap update_display WINCH

# make cursor invisible, if supported
if bb_iscmd tput; then
    tput civis
    cleanup () { tput cnorm; }
    trap cleanup EXIT  # restore back to normal on exit
fi

bb_now -v expiration
(( expiration += countdown ))

while true; do
    bb_now -v now
    (( countdown = expiration - now ))
    update_display
    [[ $countdown -eq 0 ]] && break
    sleep 1s
done

echo  # finish the line
