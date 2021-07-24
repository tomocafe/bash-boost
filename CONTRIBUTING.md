## Philosophy

- Always prefer pure-bash solutions whenever reasonable
- Don't reimplement existing bash features; complement them
- Functions should have a single purpose, without complicated options

## Style Guidelines

- Public functions start with `bb_` with the unique function name being written in all lowercase, no spaces. (e.g., `bb_parseargs`)
- Internal functions start with `_bb_MODULE_PKG_` where `MODULE` and `PKG` are replaced by the module and package containing the internal function.
- Public variables start with `BB_` and are in all caps (e.g., `BB_ROOT`).
- Internal variables start with `__bb_MODULE_PKG_` where `MODULE` and `PKG` are replaced by the module and package containing the internal variable.
