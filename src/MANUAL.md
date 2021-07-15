
## Package cli/arg

Routines for parsing command line arguments

### `addopt [SHORTNAME:]LONGNAME [DESCRIPTION] [DEFAULT]`

Adds a command line option to be parsed

**Arguments:**

- `SHORTNAME`: optional single character, e.g. "f" for an -f FOO option
- `LONGNAME`: required long name, e.g. "foo" for a --foo FOO option
- `DESCRIPTION`: description of the option used in help
- `DEFAULT`: the default value of the option if not given in the command line

**Notes:**

-h and --help are reserved for automatically-generated
command usage and help

### `addflag [SHORTNAME:]LONGNAME [DESCRIPTION]`

Adds a command line flag to be parsed

**Arguments:**

- `SHORTNAME`: optional single character, e.g. "f" for an -f flag
- `LONGNAME`: required long name, e.g. "foo" for a --foo flag
- `DESCRIPTION`: description of the option used in help

**Notes:**

-h and --help are reserved for automatically-generated
command usage and help

### `usage`

Print the command line usage string

### `help`

Print the command line help

**Notes:**

Includes the usage string and a list of flags and options with their
descrptions.

### `errusage MESSAGE [RETURNVAL]`

Issues an error message, prints the command usage, and exits the shell

**Arguments:**

- `MESSAGE`: error message to be printed
- `RETURNVAL`: return code to exit with (defaults to 1)

### `isflag LONGNAME`

Check if LONGNAME is a registered flag (not an option)

**Returns:** 0 if LONGNAME is a flag, 1 otherwise (i.e. it is an option)

### `setprog PROGNAME`

Sets the name of the program for printing usage and help

**Arguments:**

- `PROGNAME`: name of the program

### `setpositional NAME DESCRIPTION`

Sets the name and description of the positional arguments

**Arguments:**

- `NAME`: one-word name of the positional arguments (auto-capitalized)
- `DESCRIPTION`: description of the positionals used in help

### `parseargs ARGS`

Parses command line arguments after registering valid flags and options

**Arguments:**

- `ARGS`: the list of command line arguments, usually "$@"

### `getopt LONGNAME`

Gets the value of option named LONGNAME

**Arguments:**

- `LONGNAME`: long name of the option

### `checkopt LONGNAME`

Returns the value of flag named LONGNAME

**Arguments:**

- `LONGNAME`: long name of the flag

**Returns:** the flag value

### `getpositionals`

Gets the list of positional argument values

### `argclear`

Clears all registered argument parsing settings

**Notes:**

Only one "command" can be registered for parsing at once
so this can be used to clear the state of a previous command
and start a new one

## Package cli/msg

Messaging routines

### `info MESSAGE`

Prints an informational message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

### `warn MESSAGE`

Prints a warning message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

### `error MESSAGE`

Prints an error message to stderr

**Arguments:**

- `MESSAGE`: message to be printed

### `fatal MESSAGE [RETURNCODE]`

Prints an error message to stderr and then exits the shell

**Arguments:**

- `MESSAGE`: message to be printed
- `RETURNCODE`: return code to exit with (defaults to 1)

### `expect VAL1 VAL2 [MESSAGE] [RETURNCODE]`

Issues a fatal error if two given values are not equal

**Arguments:**

- `VAL1`: value to check
- `VAL2`: value to check against (golden answer)
- `MESSAGE`: optional prefix to the error message
- `RETURNCODE`: return code to exit with (defaults to 1)

### `expectsubstr VAL1 VAL2 [MESSAGE] [RETURNCODE]`

Issues a fatal error if a given substring is not found in some given text

**Arguments:**

- `VAL1`: text to check
- `VAL2`: substring to be found
- `MESSAGE`: optional prefix to the error message
- `RETURNCODE`: return code to exit with (defaults to 1)

## Package cli/color

Routines for printing text in color using ANSI escape codes

### `colorize COLORSTR TEXT`

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

### `rawcolor COLORSTR TEXT`

Like colorize but always uses prints in color

**Arguments:**

- `COLORSTR`: FGCOLOR[_on_[BGCOLOR]] (e.g. red, bright_red, white_on_blue)
- `TEXT`: text to be printed in color

**Notes:**

Use this instead of colorize if you need to still print in color even if
not connected to a terminal, e.g. when saving the output to a variable.
See colorize for supported colors

### `strip TEXT`

Strips ANSI color codes from text colorized by colorize (or rawcolor)

**Arguments:**

- `TEXT`: text possibly with color escape codes to be removed

**Notes:**

This is only guaranteed to work on text generated by colorize and
variants, but not for any generic string with ANSI escape codes.

## Package interactive/prompt

Routines for managing a dynamic shell prompt

### `loadprompt`

Activates the registered dynamic prompt

### `unloadprompt`

Deactivates the registered dynamic prompt

**Notes:**

This will restore the prompt to the state it was in
when loadprompt was called

### `setpromptleft FUNCTION ...`

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

### `setpromptright FUNCTION ...`

Sets the right prompt to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will be added to the prompt

### `setpromptnextline FUNCTION ...`

Sets the next line prompt to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will be added to the prompt

### `setwintitle FUNCTION`

Sets the window title to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will used as the window title

### `settabtitle FUNCTION`

Sets the tab title to the output of the list of given functions

**Arguments:**

- `FUNCTION`: a function whose stdout output will used as the tab title

**Notes:**

Not all terminals support this

### `promptcolor COLORSTR TEXT`

Prints text in color, for use specifically in prompts

**Arguments:**

- `COLORSTR`: valid color string, see bb_cli_color_colorize
- `TEXT`: text to be printed in color

**Notes:**

This is like colorize but adds \[ and \] around non-printing
characters which are needed specifically in prompts

## Package interactive/cmd

Miscellaneous interactive commands

### `mcd DIR`

Make director(ies) and change directory to the last one

**Arguments:**

- `DIR`: usually a single directory to be made, but all arguments are passed to 
mkdir and the last argument is then passed to cd if mkdir is successful

### `up [DIR]`

Change directory up

**Arguments:**

- `DIR`: go to this directory, otherwise defaults to .. if no DIR specified

**Notes:**

Most useful with the associated command completion. After pressing TAB,
the current working directory is populated, and with each further TAB,
a directory is removed, moving you up the directory stack. Once you see
the upward directory you want to go to, hit ENTER

## Package util/env

Routines for checking and setting environment variables

### `checkset VAR`

Check if an environment variable is set or empty

**Arguments:**

- `VAR`: name of the variable to check (don't include $)

**Returns:** 1 if unset, 2 if set but empty, 0 otherwise

### `iscmd COMMAND`

Check if COMMAND is a valid command

**Arguments:**

- `COMMAND`: name of command to check (e.g., ls)

**Notes:**

This could be an executable in your PATH, or a function or
bash builtin

### `inpath VAR ITEM ...`

Checks if items are in the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to find in the path variable

**Returns:** 0 if all items are in the path, 1 otherwise

### `prependpath VAR ITEM ...`

Prepends items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

### `appendpath VAR ITEM ...`

Appends items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

### `prependpathuniq VAR ITEM ...`

Prepends unique items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

**Notes:**

If an item is already in the path, it is not added twice

### `appendpathuniq VAR ITEM ...`

Appends unique items to the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to add to the path variable

**Notes:**

If an item is already in the path, it is not added twice

### `removefrompath VAR ITEM ...`

Removes items from the colon-separated path variable VAR

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `ITEM`: items to remove from the path variable

**Returns:** 0 if any item was removed, 1 otherwise

### `swapinpath VAR ITEM1 ITEM2`

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

### `printpath VAR [SEP]`

Prints a path variable separated by SEP, one item per line

**Arguments:**

- `VAR`: path variable, e.g. PATH (do not use $)
- `SEP`: separator character, defaults to :

## Package util/math

Routines for common math operations

### `sum NUM ...`

Returns the sum of the given numbers

**Arguments:**

- `NUM`: a valid number

### `min NUM ...`

Returns the minimum of the given numbers

**Arguments:**

- `NUM`: a valid number

### `max NUM ...`

Returns the maximum of the given numbers

**Arguments:**

- `NUM`: a valid number

### `isint NUM ...`

Checks if all the given numbers are valid integers

**Arguments:**

- `NUM`: a number to check

**Returns:** 0 if all arguments are integers, 1 otherwise

## Package util/kwargs

Routines for parsing keyword arg strings

### `kwparse KEY=VAL ...`

Parses a list of KEY=VAL pairs and stores them into a global dictionary

**Arguments:**

- `KEY=VAL`: a key-value pair separated by =

**Notes:**

kwparse stores key-value pairs into a single, global dictionary

### `kwget KEY`

Gets the value associated with a key stored with kwparse

**Arguments:**

- `KEY`: the key

### `kwclear`

Clears the global dictionary

## Package util/list

Routines for common list operations

### `join SEP ITEM ...`

Joins the list of items into a string with the given separator

**Arguments:**

- `SEP`: separator
- `ITEM`: a list item 

### `split LISTVAR SEP STR`

Splits a string based on a separator and stores the resulting list into
the specified list variable

**Arguments:**

- `LISTVAR`: name of variable to store resulting list into (do not include $)
- `SEP`: separator
- `STR`: string to split

### `inlist TARGET LIST ...`

Checks if a target item exists in a given list

**Arguments:**

- `TARGET`: the search target
- `LIST`: a list item

**Returns:** 0 if found, 1 otherwise

### `push LISTVAR ITEM`

Pushes an item to a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `ITEM`: item to push

### `pop LISTVAR`

Pops an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)

### `unshift LISTVAR ITEM`

Unshifts an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)
- `ITEM`: item to unshift

### `shift LISTVAR`

Shifts an item from a list (stack)

**Arguments:**

- `LISTVAR`: name of the list variable (do not include $)

### `sort ITEM ...`

Sorts the items of a list in lexicographic ascending order

**Arguments:**

- `ITEM`: a list item

### `sortdesc ITEM ...`

Sorts the items of a list in lexicographic descending order

**Arguments:**

- `ITEM`: a list item

### `sortnums ITEM ...`

Sorts the items of a list in numerical ascending order

**Arguments:**

- `ITEM`: a list item

### `sortnumsdesc ITEM ...`

Sorts the items of a list in numerical descending order

**Arguments:**

- `ITEM`: a list item

### `sorthuman ITEM ...`

Sorts the items of a list in human-readable ascending order

**Arguments:**

- `ITEM`: a list item

**Notes:**

Human readable, e.g., 1K, 2M, 3G

### `sorthumandesc ITEM ...`

Sorts the items of a list in human-readable descending order

**Arguments:**

- `ITEM`: a list item

**Notes:**

Human readable, e.g., 1K, 2M, 3G

### `uniq ITEM ...`

Filters an unsorted list to include only unique items

**Arguments:**

- `ITEM`: a list item

### `uniqsorted ITEM ...`

Filters an sorted list to include only unique items

**Arguments:**

- `ITEM`: a list item

**Notes:**

Faster than uniq, but requires the list to be pre-sorted

## Package util/prof

Routines for runtime profiling of bash scripts

### `startprof LOGFILE`

Starts runtime profiling

**Arguments:**

- `LOGFILE`: (optional) file use to log profiling data
Default: TMPDIR/bbprof.PID.out

**Notes:**

Use the bbprof-read utility script to parse and analyze profile data

### `stopprof`

Stops runtime profiling

## Package util/string

Routines for common string operations

### `snake2camel TEXT`

Converts text from snake to camel case

**Arguments:**

- `TEXT`: text in snake case

**Notes:**

Leading underscores are preserved

### `camel2snake TEXT`

Converts text from camel to snake case

**Arguments:**

- `TEXT`: text in camel case

### `titlecase TEXT`

Converts text into title case (every word capitalized)

**Arguments:**

- `TEXT`: text to transform

**Notes:**

This does not check the content of the words itself and may not
respect grammatical rules, e.g. "And" will be capitalized

### `sentcase TEXT`

Converts text into sentence case (every first word capitalized)

**Arguments:**

- `TEXT`: text to transform

### `urlencode TEXT`

Performs URL (percent) encoding on the given string

**Arguments:**

- `TEXT`: text to be encoded

### `urldecode TEXT`

Decodes URL-encoded text

**Arguments:**

- `TEXT`: text to be decoded

**Returns:** 1 if the input URL encoding is malformed, 0 otherwise

## Package core

Core routines

### `load PKG ...`

Loads a module or package

**Arguments:**

- `PKG`: either a package (e.g. cli/arg) or a whole module (e.g. cli)

**Notes:**

Each package only loads once; if you happen to load one twice, the second 
time has no effect

### `is_loaded PKG`

Checks if a package is loaded already

**Arguments:**

- `PKG`: package name in internal format, e.g. bb_cli_arg

**Returns:** 0 if loaded, 1 otherwise

### `namespace PREFIX`

Aliases bash-boost functions based on prefix

**Arguments:**

- `PREFIX`: the prefix to use, e.g. "xyz" makes the function
bb_cli_arg_loadprompt aliased to xyz_loadprompt

**Notes:**

If PREFIX is an empty string, the commads just become the
base function name (e.g. loadprompt).
This will copy over any command completions as well.

### `debug TEXT`

Log text when debugging is enabled

**Arguments:**

- `TEXT`: message to be logged in debug mode

**Notes:**

Set environment variable BB_DEBUG to enable debug mode