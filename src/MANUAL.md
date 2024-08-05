---
title: BASH-BOOST(1)
author: github.com/tomocafe
date: August 4, 2024
---


# Package cli/arg

Routines for parsing command line arguments

**Example:**

```bash
bb_setprog "myprogram"
bb_addopt f:foo "Number of foos (default: 2)" 2
bb_addflag b:bar "Bar flag"
bb_setpositional "THINGS" "Things to process"
bb_parseargs "$@"
set -- "${BB_POSARGS[@]}" # $@ now only contains the positional arguments
bb_checkopt bar && echo "You gave the bar flag!"
bb_getopt -v fooval foo
[[ $fooval -gt 0 ]] || bb_errusage "foo val must be greater than 0"
echo "You set foo to $fooval"
for arg in "$@"; do
  echo "You have item $arg"
done
```

**Example:**

```bash
bb_setprog "copy"
bb_addflag "f:force" "force overwrite destination"
bb_addarg "src" "source file/directory"
bb_addarg "dst" "destination path"
bb_parseargs "$@"
bb_getopt -v src src || bb_errusage "missing required src argument"
bb_getopt -v dst fst || bb_errusage "missing required dst argument"
[[ -e "$dst" && ! bb_checkopt force ]] && bb_fatal "$dst exists"
cp "$src" "$dst"
```

## `bb_addopt [SHORTNAME:]LONGNAME [DESCRIPTION] [DEFAULT]`

Adds a command line option to be parsed

**Arguments:**

- `SHORTNAME`: optional single character, e.g. "f" for an -f FOO option
- `LONGNAME`: required long name, e.g. "foo" for a --foo FOO option
- `DESCRIPTION`: description of the option used in help
- `DEFAULT`: the default value of the option if not given in the command line

**Notes:**

-h and --help are reserved for automatically-generated
command usage and help

## `bb_addarg NAME DESCRIPTION [DEFAULT]`

Adds a named argument

**Arguments:**

- `NAME`: unique, one-word name of the argument
- `DESCRIPTION`: description of the argument used in help
- `DEFAULT`: default value if not given in the command line

## `bb_addflag [SHORTNAME:]LONGNAME [DESCRIPTION]`

Adds a command line flag to be parsed

**Arguments:**

- `SHORTNAME`: optional single character, e.g. "f" for an -f flag
- `LONGNAME`: required long name, e.g. "foo" for a --foo flag
- `DESCRIPTION`: description of the option used in help

**Notes:**

-h and --help are reserved for automatically-generated
command usage and help

## `bb_argusage`

Print the command line usage string

## `bb_arghelp`

Print the command line help

**Notes:**

Includes the usage string and a list of flags and options with their
descriptions.

## `bb_errusage MESSAGE [RETURNVAL]`

Issues an error message, prints the command usage, and exits the shell

**Arguments:**

- `MESSAGE`: error message to be printed
- `RETURNVAL`: return code to exit with (defaults to 1)

## `bb_isflag LONGNAME`

Check if LONGNAME is a registered flag (not an option)

**Returns:** 0 if LONGNAME is a flag, 1 otherwise (i.e. it is an option)

## `bb_setprog PROGNAME`

Sets the name of the program for printing usage and help

**Arguments:**

- `PROGNAME`: name of the program

## `bb_setpositional NAME DESCRIPTION`

Sets the name and description of the positional arguments

**Arguments:**

- `NAME`: one-word name of the positional arguments (auto-capitalized)
- `DESCRIPTION`: description of the positionals used in help

## `bb_parseargs ARGS`

Parses command line arguments after registering valid flags and options

**Arguments:**

- `ARGS`: the list of command line arguments, usually "$@"

**Notes:**

- Check flags with `bb_checkopt LONGNAME`
- Get option setting values or named arguments with `bb_getopt LONGNAME`
- Get positional arguments with `${BB_POSARGS[@]}` array
- If the last argument is a single dash (-), read remaining arguments from stdin

## `bb_processargs`

Parses arguments in $@ and modifies it in-place to only hold positional arguments

**Notes:**

To use this in a script, you must do `shopt -s expand_aliases`

## `bb_getopt [-v VAR] LONGNAME`

Gets the value of option or argument by name

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `LONGNAME`: long name of the option (or named argument)

**Returns:** true if the result is nonempty

## `bb_checkopt LONGNAME`

Returns the value of flag named LONGNAME

**Arguments:**

- `LONGNAME`: long name of the flag

**Returns:** the flag value, either true or false

**Notes:**

Undefined if used on an opt instead of a flag

## `bb_argclear`

Clears all registered argument parsing settings

**Notes:**

Only one "command" can be registered for parsing at once
so this can be used to clear the state of a previous command
and start a new one

# Package cli/color

Routines for printing text in color using ANSI escape codes

## `bb_colorize COLORSTR TEXT`

Prints the given text in color if outputting to a terminal

**Arguments:**

- `COLORSTR`: FGCOLOR[_on_[BGCOLOR]] (e.g. red, bright_red, white_on_blue)
- `TEXT`: text to be printed in color

**Returns:** 0 if text was printed in color, 1 otherwise

**Notes:**

Supported colors:
- black
- red
- green
- yellow
- blue
- magenta
- cyan
- bright_gray (dark_white)
- gray (bright_black)
- bright_red
- bright_green
- bright_yellow
- bright_blue
- bright_magenta
- bright_cyan
- white (bright_white)

This does not print a new line at the end of TEXT

## `bb_rawcolor COLORSTR TEXT`

Like colorize but always uses prints in color

**Arguments:**

- `COLORSTR`: FGCOLOR[_on_[BGCOLOR]] (e.g. red, bright_red, white_on_blue)
- `TEXT`: text to be printed in color

**Notes:**

Use this instead of colorize if you need to still print in color even if
not connected to a terminal, e.g. when saving the output to a variable.
See colorize for supported colors

## `bb_colorstrip TEXT`

Strips ANSI color codes from text colorized by colorize (or rawcolor)

**Arguments:**

- `TEXT`: text possibly with color escape codes to be removed

**Notes:**

This is only guaranteed to work on text generated by colorize 
and variants, not for any generic string with ANSI escape codes.

# Package cli/input

Routines for handling user input

## `bb_getinput VAR PROMPT`

Prompts for input and saves the response to VAR

**Arguments:**

- `VAR`: variable to store response into (do not include $)
- `PROMPT`: text displayed to the user

## `bb_yn PROMPT`

Prompts user to confirm an action by pressing Y

**Arguments:**

- `PROMPT`: text displayed to the user

**Returns:** 0 if yes, 1 otherwise

**Notes:**

If you want the user to type "yes", use getinput
and check their response

## `bb_pause PROMPT`

Prompts user to press a key to continue

**Arguments:**

- `PROMPT`: text displayed to the user
Default: Press any key to continue

# Package cli/msg

Messaging routines

## `bb_info MESSAGE`

Prints an informational message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

## `bb_warn MESSAGE`

Prints a warning message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

## `bb_error MESSAGE`

Prints an error message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

## `bb_fatal MESSAGE [RETURNCODE]`

Prints an error message to stderr and then exits the shell

**Arguments:**

- `MESSAGE`: message to be printed
- `RETURNCODE`: return code to exit with (defaults to 1)

## `bb_expect VAL1 VAL2 [MESSAGE] [RETURNCODE]`

Issues a fatal error if two given values are not equal

**Arguments:**

- `VAL1`: value to check
- `VAL2`: value to check against (golden answer)
- `MESSAGE`: optional prefix to the error message
- `RETURNCODE`: return code to exit with (defaults to 1)

## `bb_expectsubstr TEXT PATTERN [MESSAGE] [RETURNCODE]`

Issues a fatal error if a given substring is not found in some given text

**Arguments:**

- `TEXT`: text to check
- `PATTERN`: substring to be found
- `MESSAGE`: optional prefix to the error message
- `RETURNCODE`: return code to exit with (defaults to 1)

## `bb_expectre TEXT PATTERN [MESSAGE] [RETURNCODE]`

Issues a fatal error if text does not match the given regular expression

**Arguments:**

- `TEXT`: text to check
- `PATTERN`: regular expression
- `MESSAGE`: optional prefix to the error message
- `RETURNCODE`: return code to exit with (defaults to 1)

## `bb_loglevel [LEVEL]`

Sets the current log level

**Arguments:**

- `LEVEL`: integer representing the current log verbosity level (default: 0)

## `bb_setloglevelname LEVEL NAME`

Assigns a name to the given log level

**Arguments:**

- `LEVEL`: integer representing the current log verbosity level 
- `NAME`: name to be assigned

## `bb_log LEVEL MESSAGE`

Issues a message at a certain log level

**Arguments:**

- `LEVEL`: minimum logging level required to print the message
- `MESSAGE`: message to be printed

**Notes:**

Set BB_LOG_TIMEFMT to a valid time format string to override the default

# Package cli/progress

Text-based progress bar and checkpoint pass/fail status line generator

**Example:**

```bash
ping -c 1 8.8.8.8 &>/dev/null; bb_checkpoint "Pinging DNS"
for pct in {0..100}; do sleep 0.1s; bb_progressbar $pct "Downloading"; done; echo
```

## `bb_progressbar VALUE TEXT`

Prints/updates a progress bar

**Arguments:**

- `VALUE`: integer from 0 to 100; 100 meaning complete
- `TEXT`: optional text to be displayed

**Notes:**

Customize the start, end, and fill characters by setting environment 
variables BB_PROGRESS_START, BB_PROGRESS_END, and BB_PROGRESS_FILL.
By default these are set to [, ], and .

## `bb_checkpoint TEXT [RESULT]`

Prints a status line with pass/fail result based on RESULT

**Arguments:**

- `TEXT`: text to be displayed
- `RESULT`: 0 for pass, nonzero for fail; if not given, infers from $?

**Notes:**

Customize the fill character and pass/fail text by setting environment 
variables BB_CHECKPOINT_FILL, BB_CHECKPOINT_PASS, and BB_CHECKPOINT_FAIL.
By default these are set to space, OK, and FAIL.

# Package core

Core routines

## `bb_load PKG ...`

Loads a module or package

**Arguments:**

- `PKG`: either a package (e.g. cli/arg) or a whole module (e.g. cli)

**Notes:**

Each package only loads once; if you happen to load one twice, the second 
time has no effect

## `bb_isloaded PKG`

Checks if a package is loaded already

**Arguments:**

- `PKG`: package name in internal format, e.g. bb_cli_arg

**Returns:** 0 if loaded, 1 otherwise

## `bb_debug TEXT`

Log text when debugging is enabled

**Arguments:**

- `TEXT`: message to be logged in debug mode

**Notes:**

Set environment variable BB_DEBUG to enable debug mode

## `bb_issourced`

Check if the script is being sourced

**Returns:** 0 if sourced, 1 otherwise

## `bb_stacktrace`

Print a stack trace to stderr

## `bb_cleanup`

Clears all functions and variables defined by bash-boost

# Package interactive/bookmark

Directory bookmarking system

## `bb_addbookmark [KEY] [DIR]`

Adds a bookmark to the directory for quick recall

**Arguments:**

- `KEY`: single character to assign bookmark to
- `DIR`: directory to bookmark; defaults to current directory

**Notes:**

If DIR is already bookmarked, this will clear the previously associated key
If KEY is already used, this will overwrite the orevious assignment

## `bb_delbookmark [KEY]`


**Arguments:**

- `KEY`: bookmark key to delete; prompts if unspecified

**Notes:**

Useful as a keyboard shortcut, e.g., Ctrl+X-B

## `bb_bookmark [KEY] [DIR]`

Go to the directory bookmarked by KEY if it exists, otherwise create bookmark

**Arguments:**

- `KEY`: single character to assign bookmark to; prompts if unspecified
- `DIR`: directory to bookmark; defaults to current directory

**Notes:**

If DIR is already bookmarked, this will clear the previously associated key.
If KEY is already used but you wish to overwrite it, use bb_addbookmark or use bb_delbookmark KEY first
Useful as a keyboard shortcut, e.g., Ctrl+B

## `bb_showbookmark [KEY]`

Shows the current mapping of KEY, or all keys if KEY is unspecified

**Arguments:**

- `KEY`: bookmark key to show

## `bb_getbookmark [DIR]`

Prints bookmark key assigned to the given DIR if such a bookmark exists

**Arguments:**

- `DIR`: directory to get assigned bookmark key of; defaults to current directory

## `bb_loadbookmark FILE`

Loads bookmark assignments from FILE

**Arguments:**

- `FILE`: a file containing bookmark assignments

**Notes:**

FILE should be formatted with an assignment on each line,
with each assignment being a letter followed by a path, separated by space

# Package interactive/cmd

Miscellaneous interactive commands

## `bb_mcd DIR`

Make director(ies) and change directory to the last one

**Arguments:**

- `DIR`: usually a single directory to be made, but all arguments are passed to 
mkdir and the last argument is then passed to cd if mkdir is successful

## `bb_up [DIR]`

Change directory up

**Arguments:**

- `DIR`: go to this directory, otherwise defaults to .. if no DIR specified

**Notes:**

Most useful with the associated command completion. After pressing TAB,
the current working directory is populated, and with each further TAB,
a directory is removed, moving you up the directory stack. Once you see
the upward directory you want to go to, hit ENTER

## `bb_forkterm [ARGS ...]`

Spawn a new terminal instance inheriting from this shell's environment

**Arguments:**

- `ARGS`: arguments to be appended to the terminal launch command

**Notes:**

- Uses the BB_TERMINAL or TERMINAL environment variable as the command
to launch the new terminal instance.
- Sets the BB_FORKDIR variable for the spawned shell to read.
In your shell init file, you can  detect when this variable is set 
and change to this directory, if desired.
- BB_TERMINAL can be a list with arguments, or a string which will be
tokenized by space. If your arguments contain spaces, you will need
to declare the variable as a list.

# Package interactive/prompt

Routines for managing a dynamic shell prompt

## `bb_loadprompt`

Activates the registered dynamic prompt

## `bb_unloadprompt`

Deactivates the registered dynamic prompt

**Notes:**

This will restore the prompt to the state it was in
when loadprompt was called

## `bb_setpromptleft FUNCTION ...`

Sets the left prompt to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will be added to the prompt

**Notes:**

The prompt areas are as follows:
```
  +----------------------------------------+
  | left prompt               right prompt |
  | nextline prompt                        |
  +----------------------------------------+
```

## `bb_setpromptright FUNCTION ...`

Sets the right prompt to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will be added to the prompt

## `bb_setpromptnextline FUNCTION ...`

Sets the next line prompt to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will be added to the prompt

## `bb_setwintitle FUNCTION`

Sets the window title to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will used as the window title

## `bb_settabtitle FUNCTION`

Sets the tab title to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will used as the tab title

**Notes:**

Not all terminals support this

## `bb_promptcolor COLORSTR TEXT`

Prints text in color, for use specifically in prompts

**Arguments:**

- `COLORSTR`: valid color string, see bb_colorize
- `TEXT`: text to be printed in color

**Notes:**

This is like colorize but adds \[ and \] around non-printing
characters which are needed specifically in prompts

# Package util/env

Routines for checking and setting environment variables

## `bb_checkset VAR`

Check if an environment variable is set or empty

**Arguments:**

- `VAR`: name of the variable to check (don't include $)

**Returns:** 1 if unset, 2 if set but empty, 0 otherwise

## `bb_iscmd COMMAND`

Check if COMMAND is a valid command

**Arguments:**

- `COMMAND`: name of command to check (e.g., ls)

**Notes:**

This could be an executable in your PATH, or a function or
bash builtin

## `bb_inpath VAR ITEM ...`

Checks if items are in the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to find in the path variable

**Returns:** 0 if all items are in the path, 1 otherwise

## `bb_prependpath VAR ITEM ...`

Prepends items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

## `bb_appendpath VAR ITEM ...`

Appends items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

## `bb_prependpathuniq VAR ITEM ...`

Prepends unique items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

**Notes:**

If an item is already in the path, it is not added twice

## `bb_appendpathuniq VAR ITEM ...`

Appends unique items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

**Notes:**

If an item is already in the path, it is not added twice

## `bb_removefrompath VAR ITEM ...`

Removes items from the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to remove from the path variable

**Returns:** 0 if any item was removed, 1 otherwise

## `bb_swapinpath VAR ITEM1 ITEM2`

Swaps two items in a colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM1`: first item to swap
- `ITEM2`: second item to swap

**Returns:** 
0 if swap is successful,
1 if either ITEM1 or ITEM2 was not in the path
2 if insufficient arguments were supplied (less than 3)
3 for internal error

## `bb_printpath VAR [SEP]`

Prints a path variable separated by SEP, one item per line

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `SEP`: separator character, defaults to :

# Package util/file

Routines for common file operations

## `bb_canonicalize [-v VAR] PATH`

Resolves . and .. in a given absolute path

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `PATH`: an absolute path

**Returns:** 1 if PATH is invalid, 0 otherwise

## `bb_abspath [-v VAR] TARGET [FROM]`

Returns the absolute path from a relative one

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TARGET`: target relative path (can be file or directory)
- `FROM`: the absolute directory path from which the absolute path is formed
(Defaults to $PWD)

## `bb_relpath [-v VAR] TARGET [FROM]`

Returns the relative path from a directory to the target

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TARGET`: target absolute path (can be file or directory)
- `FROM`: the absolute directory path from which the relative path is formed
(Defaults to $PWD)

**Returns:** 1 if either TARGET or FROM is invalid, 0 otherwise

## `bb_prettypath PATH`

Prints a pretty version of the path

**Arguments:**

- `PATH`: a path

**Notes:**

Replaces home directory with ~

## `bb_countlines FILENAME ...`

Counts the number of lines in a list of files

**Arguments:**

- `FILENAME`: a valid filename

**Returns:** 1 if any of the filenames are invalid, 0 otherwise

## `bb_countmatches PATTERN FILENAME ...`

Counts the number of matching lines in a list of files

**Arguments:**

- `PATTERN`: a valid bash regular expression
- `FILENAME`: a valid filename

**Returns:** 1 if any of the filenames are invalid, 0 otherwise

## `bb_extpush EXT FILENAME ...`

Adds the file extension EXT to all given files

**Arguments:**

- `EXT`: the file extension
- `FILENAME`: a valid filename

## `bb_extpop FILENAME ...`

Removes the last file extension from the given files

**Arguments:**

- `FILENAME`: a valid filename

## `bb_hardcopy FILENAME ...`

Replaces symbolic links with deep copies

**Arguments:**

- `FILENAME`: a valid symbolic link

## `bb_scriptpath [-v VAR]`

Returns the unresolved directory name of the current script

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)

# Package util/kwargs

Routines for parsing keyword arg strings

**Example:**

```bash
talk() {
  bb_kwparse opts "$@"
  set -- "${BB_OTHERARGS[@]}" # $@ now only contains non-kwargs
  local verb="${opts[verb]:-have}"
  local item
  for item in "$@"; do
    echo "You $verb $item"
  done
}
talk eggs milk bread
talk verb=ate eggs milk bread
```

## `bb_kwparse MAP KEY=VAL ... ARGS ...`

Parses a list of KEY=VAL pairs and stores them into a dictionary

**Arguments:**

- `MAP`: name of an associative array to be created
- `KEY=VAL`: a key-value pair separated by =
- `ARGS`: other arguments not in KEY=VAL format are ignored

**Notes:**

Get non-keyword arguments with ${BB_OTHERARGS[@]}

# Package util/list

Routines for common list operations

## `bb_join [-v VAR] SEP ITEM ...`

Joins the list of items into a string with the given separator

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `SEP`: separator
- `ITEM`: a list item 

## `bb_split [-V LISTVAR] SEP STR`

Splits a string into a list based on a separator

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `SEP`: separator
- `STR`: string to split

## `bb_inlist TARGET LIST ...`

Checks if a target item exists in a given list

**Arguments:**

- `TARGET`: the search target
- `LIST`: a list item

**Returns:** 0 if found, 1 otherwise

## `bb_push LISTVAR ITEM ...`

Pushes an item to a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `ITEM`: item to push

## `bb_pop LISTVAR`

Pops an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)

## `bb_unshift LISTVAR ITEM ...`

Unshifts an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `ITEM`: item to unshift

## `bb_shift LISTVAR`

Shifts an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)

## `bb_sort [-V LISTVAR] ITEM ...`

Sorts the items of a list in lexicographic ascending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

## `bb_sortdesc [-V LISTVAR] ITEM ...`

Sorts the items of a list in lexicographic descending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

## `bb_sortnums [-V LISTVAR] ITEM ...`

Sorts the items of a list in numerical ascending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

## `bb_sortnumsdesc [-V LISTVAR] ITEM ...`

Sorts the items of a list in numerical descending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

## `bb_sorthuman [-V LISTVAR] ITEM ...`

Sorts the items of a list in human-readable ascending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

**Notes:**

Human readable, e.g., 1K, 2M, 3G

## `bb_sorthumandesc [-V LISTVAR] ITEM ...`

Sorts the items of a list in human-readable descending order

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

**Notes:**

Human readable, e.g., 1K, 2M, 3G

## `bb_uniq [-V LISTVAR] ITEM ...`

Filters an unsorted list to include only unique items

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

## `bb_uniqsorted [-V LISTVAR] ITEM ...`

Filters an sorted list to include only unique items

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `ITEM`: a list item

**Notes:**

Faster than uniq, but requires the list to be pre-sorted

## `bb_islist LISTVAR`

Checks if the variable with the given name is a list with >1 element

**Arguments:**

- `LISTVAR`: name of a variable

**Notes:**

This will return false if the variable is declared as a list 
but only has 1 element. In that case, you can treat the variable
as a scalar anyway.

## `bb_rename ITEM ... -- NAME ...`

Assigns new variable names to items

**Arguments:**

- `ITEM`: a list item
- `NAME`: a variable name

**Example:**

```bash
func() {
  bb_rename "$@" -- first second
  echo "The first argument is $first"
  echo "The second argument is $second"
}
```

## `bb_unpack LISTVAR NAME ...`

Unpacks list items into named variables

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `NAME`: a variable name to hold a list element

## `bb_map LISTVAR FUNCTION`

Maps a function over a list, modifying it in place

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `FUNCTION`: a function or command to map a list element to a new value

# Package util/math

Routines for common math operations

## `bb_sum [-v VAR] NUM ...`

Returns the sum of the given numbers

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `NUM`: a valid number

## `bb_min [-v VAR] NUM ...`

Returns the minimum of the given numbers

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `NUM`: a valid number

## `bb_max [-v VAR] NUM ...`

Returns the maximum of the given numbers

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `NUM`: a valid number

## `bb_abs [-v VAR] NUM`

Returns the absolute value of a given number

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `NUM`: a valid number

## `bb_isint NUM ...`

Checks if all the given numbers are valid integers

**Arguments:**

- `NUM`: a number to check

**Returns:** 0 if all arguments are integers, 1 otherwise

## `bb_hex2dec [-V LISTVAR] NUM ...`

Converts numbers from hexademical (base 16) to decimal (base 10)

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `NUM`: a number to convert

**Returns:** 1 if any number is invalid hexadecimal, 0 otherwise

## `bb_dec2hex [-V LISTVAR] NUM ...`

Converts numbers from decimal (base 10) to hexademical (base 16)

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `NUM`: a number to convert

**Returns:** 1 if any number is invalid decimal, 0 otherwise

## `bb_oct2dec [-V LISTVAR] NUM ...`

Converts numbers from octal (base 8) to decimal (base 10)

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `NUM`: a number to convert

**Returns:** 1 if any number is invalid octal, 0 otherwise

## `bb_dec2oct [-V LISTVAR] NUM ...`

Converts numbers from decimal (base 10) to octal (base 8)

**Arguments:**

- `LISTVAR`: list variable to store result (if not given, prints to stdout)
- `NUM`: a number to convert

**Returns:** 1 if any number is invalid decimal, 0 otherwise

# Package util/prof

Routines for runtime profiling of bash scripts

## `bb_startprof LOGFILE`

Starts runtime profiling

**Arguments:**

- `LOGFILE`: (optional) file use to log profiling data
Default: TMPDIR/bbprof.PID.out

**Notes:**

Use the bbprof-read utility script to parse and analyze profile data

## `bb_stopprof`

Stops runtime profiling

# Package util/string

Routines for common string operations

## `bb_lstrip [-v VAR] TEXT`

Strips leading (left) whitespace from text

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to strip whitespace from

## `bb_rstrip [-v VAR] TEXT`

Strips trailing (right) whitespace from text

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to strip whitespace from

## `bb_strip [-v VAR] TEXT`

Strips leading and trailing whitespace from text

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to strip whitespace from

## `bb_ord [-v VAR] CHAR`

Converts character to its ASCII decimal code

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `CHAR`: a single character 

## `bb_chr [-v VAR] CODE`

Converts ASCII decimal code to character

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `CODE`: an integer ASCII character code

## `bb_snake2camel [-v VAR] TEXT`

Converts text from snake to camel case

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text in snake case

**Notes:**

Leading underscores are preserved

## `bb_camel2snake [-v VAR] TEXT`

Converts text from camel to snake case

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text in camel case

## `bb_titlecase [-v VAR] TEXT`

Converts text into title case (every word capitalized)

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to transform

**Notes:**

This does not check the content of the words itself and may not
respect grammatical rules, e.g. "And" will be capitalized

## `bb_sentcase [-v VAR] TEXT`

Converts text into sentence case (every first word capitalized)

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to transform

## `bb_urlencode [-v VAR] TEXT`

Performs URL (percent) encoding on the given string

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to be encoded

## `bb_urldecode [-v VAR] TEXT`

Decodes URL-encoded text

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `TEXT`: text to be decoded

**Returns:** 1 if the input URL encoding is malformed, 0 otherwise

## `bb_repeatstr [-v VAR] NUM TEXT`

Repeat TEXT NUM times

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `NUM`: repeat this many times (integer)
- `TEXT`: text to repeat

## `bb_centerstr [-v VAR] WIDTH TEXT [FILL]`

Pad and center TEXT with FILL character to have WIDTH width

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `WIDTH`: width of the padded string result
- `TEXT`: text to display
- `FILL`: character used for padding (if not given, uses space)

**Notes:**

If the text cannot be perfectly centered, it will be pushed
closer to the left side. TEXT may contain color codes.

## `bb_cmpversion VER1 VER2 [DELIM]`

Checks if VER1 is greater than or equal to VER2

**Arguments:**

- `VER1`: a version string (containing only numerals and delimeters)
- `VER2`: another version string, usually a reference point
- `DELIM`: character(s) to delimit fields in the version string (default: .-_)

**Returns:** 0 if VER1 greater or equal to VER2, 1 otherwise

**Notes:**

Numeric comparison is used, so alphabetical characters are not supported

# Package util/time

Routines for common time and date operations

**Example:**

```bash
bb_timefmt "%F %T" # e.g., 2022-11-20 16:53:30
bb_timefmt "%F %T" $(bb_now +1h) # one hour from now
bb_timefmt "%F %T" $(bb_now ^h)  # end of the hour
bb_timefmt "%F %T" $(bb_now +1d) # one day from now
bb_timefmt "%F %T" $(bb_now ^d)  # end of the day
bb_timefmt "%F %T" $(bb_now +2w ^d) # after two weeks, at end of day
```

## `bb_now [-v VAR] [OFFSET ...]`

Returns a timestamp relative to the current time (in seconds after epoch)

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `OFFSET`: {+,-}N{s,m,h,d,w}[^] where N is an integer

**Returns:** 1 if any offset is invalid, 0 otherwise

**Notes:**

s: seconds
m: minutes
h: hours
d: days
w: weeks
Optional: trailing ^ rounds up; ^d is short for +0d^

## `bb_timefmt [-v VAR] FORMAT [TIMESTAMP]`

Formats a timestamp into a desired date format

**Arguments:**

- `VAR`: variable to store result (if not given, prints to stdout)
- `FORMAT`: date format string, refer to man strftime
- `TIMESTAMP`: epoch time, defaults to current time (now)

## `bb_timedeltafmt [-v VAR] FORMAT TIME1 [TIME2]`

Formats a time delta into a desired format

**Arguments:**

- `VAR`:
- `FORMAT`:
- `TIME1`: if TIME1 not specified, this is interpreted as a duration in seconds
- `TIME2`: if specified, TIME1 is the end timestamp and TIME2 is the start timestamp

**Notes:**

Capital letters D, H, M, S represent the partial value
Lowercase letters d, h, m, s represent the total value

**Example:**

```bash
bb_now -v start
sleep 120s
bb_now -v end
bb_timedeltafmt -v elapsed "%H:%M:%S" end start
bb_timedeltafmt -v total_seconds "%s" end start
echo "elapsed time $elapsed, $total_seconds total seconds"
# above should print "elapsed time 00:02:00, 120 total seconds"
```
