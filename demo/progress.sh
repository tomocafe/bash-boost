#!/usr/bin/env bash

# Demo: progress bar

source ../latest/bash-boost.sh

bb_load cli/progress

for i in {0..100..5}; do
    sleep 0.1s
    bb_progressbar $i "Initializing"
done
echo

for i in {0..100}; do
    if [[ $i -gt 60 && $i -lt 70 ]]; then
        sleep 0.5s
        bb_progressbar $i "Thinking really hard"
    else
        sleep 0.1s
        bb_progressbar $i "Reticulating splines"
    fi
done
echo "Done."

