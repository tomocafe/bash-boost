changecom()dnl
#
# bash-boost `v'M4_VERSION
# 
# MIT License
# 
# Copyright (c) 2021 Evan Wegley (github.com/tomocafe)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# INSTRUCTIONS:
# 
# Source this script from your script or interactive environment
# and optionally give packages to load via argument:
#
#   source /full/path/to/bash-boost.sh [PKGS ...]
# 
# After sourcing you can load packages using bb_load:
#
#   bb_load cli         # all cli packages (cli/*)
#   bb_load util/math   # only the util/math package
#
# To get help on functions and variables exported by packages,
# check the documentation.

BB_VERSION="M4_VERSION"

# Check bash version
if [[ ${BASH_VERSINFO:-0} -lt 4 ]]; then
    echo "${BASH_SOURCE[0]##*/}: requires bash version 4 or later, this is $BASH_VERSION" 1>&2
    return 1
fi

# Load the core
BB_ROOT="$(dirname "${BASH_SOURCE[0]}")"
# flatten-begin-exclude
source $BB_ROOT/core/core.sh

# Load packages by argument
# Alternatively, caller can use bb_load after sourcing this function
for arg in "$@"; do
    bb_load "$arg"
done
# flatten-end-exclude

# flatten-include-here

# Clean up
unset arg
unset this
