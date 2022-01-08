## Philosophy

### Prefer pure-bash solutions

Try not to use external processes, pipes, etc. unless there is a compelling reason. The user can do this themselves, without much need to use bash-boost. Especially for things like `sed`, `awk`, `cut`, `grep` (use parameter expansion and bash regex support instead).

An interesting counterpoint is list sorting ([util/list.sh](util/list)). Implementing a sorting algorithm in pure bash is out of scope of this project, but deemed common enough to wrap in functions.

### Don't reimplement existing bash features, complement them

For example, don't introduce a function such as `bb_uppercase` which can be done in pure bash with `${VAR^^}` (parameter expansion).

A bash-boost function should be a useful combination of pure bash features. An exception may arise where introducing a function that wraps a single bash feature or builtin is allowed because it drastically simplifies and reduces typing.

### Functions should have a single purpose, without complicated options

A good example is the splitting of list sorting functions in [util/list.sh](util/list). Rather than a monolithic `bb_sort` function, the interface is split into functions such as `bb_sort`, `bb_sortdesc`, `bb_sortnums`, etc. The implementation of these routines is common, however.

### Avoid cluttering the user's environment

Use `local` in functions to avoid leaking internal variables. Carefully consider introducing a new global variable.

## Style Guidelines

- Public functions start with `bb_` with the unique function name being written in all lowercase, no spaces. (e.g., `bb_parseargs`)
- Internal functions start with `_bb_MODULE_PKG_` where `MODULE` and `PKG` are replaced by the module and package containing the internal function.
- Public variables start with `BB_` and are in all caps (e.g., `BB_ROOT`).
- Internal variables start with `__bb_MODULE_PKG_` where `MODULE` and `PKG` are replaced by the module and package containing the internal variable.

## Logistics

### Packages

When developing a new package, choose an appropriate module.

- **cli** -- for command line scripts
- **interactive** -- for use in the interactive shell
- **util** -- helpers for both CLI and interactive use

A script developer may wish to include only the **cli** module to avoid sourcing unneeded interactive features. Likewise, a user may load the **interactive** module in their `bashrc` file and not the **cli** module.

A new module may be considered if it poses a use case that is truly unique to the existing ones.

For the package `bar` under module `foo`, a file `foo/bar.sh` should be created under `src` which starts with:

```shell
# @package: foo/bar
# Description of the package here

_bb_onfirstload "bb_foo_bar" || return

################################################################################
# Globals
################################################################################

################################################################################
# Functions
################################################################################

```

Any global variables should go in the _Globals_ section and follow the naming conventions outline in the _Style Guidelines_ section.

Functions go in the _Functions_ section.

After adding a new package, you must add it to the module's `_load.sh` file. For example, in `foo/_load.sh`:

```shell
source "$BB_ROOT/foo/bar.sh"
```

### Functions

Function names must be unique across packages _and_ modules! Use `make check` to find collisions.

When creating a function (e.g. `baz`) within a package, follow this convention:

```shell
# function: bb_baz [-v VAR] ARGS ...
# Brief description of the function
# @arguments:
# - VAR: variable to store result (if not given, prints to stdout)
# - ARGS: argument description
function bb_baz () {
    _bb_glopts "$@"; set -- "${__bb_args[@]}"
    # Implement function here
    # Access function arguments with $@ ($1, $2, ...)
    # e.g. put result in $result
    _bb_result "$result"
}
```

The header (function contract) above the function is used in the auto-generated manual.

Though not technically needed, the `function` keyword is required for parsing purposes.

Use the boilerplate code

```shell
_bb_glopts "$@"; set -- "${__bb_args[@]}"
```

to interpret global function options (`-v`, `-V`, `--`, `-`) and clean up the argument list for use in your function.

If your function returns a value, pass it to the `_bb_result` function, which handles the output based on the global options (i.e., prints to stdout or stores to variable)

### Testing

All functions should be tested in the module's `_test.sh` script. This is exercised with `make test`. See existing tests for examples. The `bb_expect` function is handy for creating such tests.
