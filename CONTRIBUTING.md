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
