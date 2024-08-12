# Countdown Timer

A question was asked on Reddit how to make a countdown timer with the following requirements:

* The timer counts down from a user-specified number of hours, minutes, and seconds
* The current countdown value is displayed in the format `HH:MM:SS` on a single line that overwrites itself each second, with the countdown center-justified
* The countdown value starts at green, then changes to yellow when it reaches a certain value, and finally red when it reaches another value

On the surface, this sounds like a trivial task, but after thinking about it, there are a few interesting tidbits.

## Specifying the countdown value

We could accept the hours, minutes, and seconds using separate command line options; or we might accept a single _time string_ in the form `[H:[M:]]S` which takes precedence over the command line options.

In other words, we would want the following command line invocations to result in the same countdown:

| Command line arguments | Countdown (formatted) | Countdown (in seconds) |
| ---------------------- | --------------------- | ---------------------- |
| `-H 1 -M 23 -S 45`     | `01:23:45`            | 5025                   |
| `-M 83 -S 45`          | `01:23:45`            | 5025                   |
| `01:23:45`             | `01:23:45`            | 5025                   |

We'll start by loading some bash-boost packages and parsing the command line arguments.

```bash
bb_load cli/arg util/list

bb_addopt H:hours "number of hours"   0
bb_addopt M:mins  "number of minutes" 0
bb_addopt S:secs  "number of seconds" 0
bb_setpositional "TIMESTR" "time string in the form [H:[M:]]S"
bb_setprog
bb_parseargs "$@"
set -- "${BB_POSARGS[@]}" # $@ now only contains the positional arguments
```

We'll want to convert the arguments into a number of seconds to count down from.

If given a time string, we can split the string into hour, minute, and second parts; otherwise we can read them directly from the command line switches.

```bash
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
        countdown+=$(( ${hms[-1]} * ${secfactor[0]} ))
        bb_pop hms
        bb_shift secfactor
    done
else
    bb_getopt -v h hours
    bb_getopt -v m mins
    bb_getopt -v s secs
    countdown=$(( h * 3600 + m * 60 + s ))
fi
```

## Display

To format a countdown value stored in total seconds as a time string (`HH:MM:SS`) we can use the `bb_timedeltafmt` function.

Printing in color and centering the output in the terminal isn't rocket science, but bash-boost also makes this significantly easier.

Note that we can enable the `checkwinsize` shell option so that `$COLUMN` is continually updated with the current column width of the terminal.

```bash
shopt -s checkwinsize

bb_load cli/color util/string util/time

turn_yellow=60  # can be specified by command line argument
turn_red=10

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
    bb_timedeltafmt -v timestr "%H:%M:%S" $countdown
    # build line
    local line
    bb_centerstr -v line $COLUMNS "$(bb_rawcolor $color "$timestr")"
    # print line with leading carriage return to overwrite the previous line
    printf "\r%s" "$line"
}
```

## Accuracy

This is a simple way to make the timer tick each second:

```bash
while [[ $countdown -gt 0 ]]; do
    update_display
    let countdown--
    sleep 1s
done
update_display # show 00:00:00
```

While this works fine for small countdown values, each iteration of the loop takes slightly more than 1 second since (primarily) the `update_display` function takes some amount of time to prepare the output and print it to the terminal.

If you run this loop thousands of times for a countdown on the order of hours, you'll find that the countdown ends later than it should, since all that extra time adds up. (*How* much extra time each iteration takes depends on your computer and the current system load.)

An alternative method is to calculate the epoch time when the timer should end. Then each iteration of the loop would simply check if the expiration time has been reached to end the loop, as well as updating the display.

```bash
bb_now -v expiration
(( expiration += countdown ))

while true; do
    bb_now -v now
    (( countdown = expiration - now ))
    update_display
    [[ $countdown -eq 0 ]] && break
    sleep 1s
done
```

Note that the new loop can result in the seconds display going down by 2 instead of 1 as normal when it needs to "catch up" due to the added slowdown of `update_display`. You could theoretically reduce the sleep value to 0.5s (or lower) so that the display always reduces by 1 second when it changes, though in cases where it needs to "catch up", you will see the "skipped" second flash by quickly.

## Other niceties

We can hide the cursor when the countdown is underway and also cause the display to update whenever the window size changes using these `trap` commands:

```bash
# update display whenever the terminal width is changed
trap update_display WINCH

# make cursor invisible, if supported
if bb_iscmd tput; then
    tput civis
    cleanup () { tput cnorm; }
    trap cleanup EXIT  # restore back to normal on exit
fi
```

Let's also add some additional command line settings for the user to configure the yellow and red time values and the time display format.

```bash
bb_addopt y:yellow  "color display yellow at this second value" 60
bb_addopt r:red     "color display red at this second value"    10
bb_addopt F:timefmt "time format (default: %H:%M:%S)" "%H:%M:%S"
```

## Putting it all together

See [countdown.sh](countdown.sh) for a complete demo which comprises these code snippets.
