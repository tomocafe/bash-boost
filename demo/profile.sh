#!/usr/bin/env bash

# Demo: runtime profiling using util/prof routines

here="${BASH_SOURCE[0]%/*}"

source ../latest/bash-boost.sh

bb_load util/prof
bb_load util/file # for bb_relpath, etc.

echo "Waiting for 1 second"
sleep 1

echo "Starting runtime profiling"
bb_startprof

for i in {2..4}; do
    echo "Waiting for $i seconds"
    sleep $i
done

bb_stopprof

echo "Ended runtime profile"
echo "Runtime profile data is in: $__bb_util_prof_logfile"
echo "Analyzing with $(bb_relpath "$(bb_abspath "$here/../bin/bbprof-read")")"

"$here/../bin/bbprof-read" "$__bb_util_prof_logfile"
