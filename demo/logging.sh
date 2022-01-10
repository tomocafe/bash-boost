#!/bin/bash

# Demo: using logging

source ../latest/bash-boost.sh

bb_load cli/msg

bb_setloglevelname 2 "debug"
bb_setloglevelname 3 "trace"
#BB_LOG_TIMEFMT="%X" # uncomment for time only (no date)

logger () {
    bb_log 1 "this is logged output"
    bb_log 2 "this is a debug message"
    bb_log 3 "this is a trace message"
}

echo "No logging enabled"
logger

for i in {1..3}; do
    echo "Log level $i enabled"
    bb_loglevel $i
    logger
done

