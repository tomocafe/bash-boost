# bash-boost

bash-boost is a set of library functions for bash, useful for both scripting and interactive use. It draws inspiration from the [Boost](https://boost.org) C++ libraries.

## Philosophy

- Always prefer pure-bash solutions whenever reasonable
- Don't reimplement existing bash features; complement them
- Functions should have a single purpose, without complicated options



## Requirements

`bash` 4.x or later

## Installation

TO DO

## Organization

bash-boost consists of the following _modules_, each with different _packages_

- [**cli**](src/cli) - for command-line (script) use
  - [arg](src/cli/arg.sh) - for parsing command line arguments
  - [color](src/cli/color.sh) - for printing text in color
  - [input](src/cli/input.sh) - for handling user input
  - [msg](src/cli/msg.sh) - for messaging and logging
- [**interactive**](src/interactive) - for interactive use
  - [cmd](src/interactive/cmd.sh) - miscellaneous interactive commands
  - [prompt](src/interactive/prompt.sh) - dynamic shell prompt
- [**util**](src/util) - general purpose routines
  - [env](src/util/env.sh) - for checking and setting environment variables
  - [file](src/util/file.sh) - file and filesystem related operations
  - [kwargs](src/util/kwargs.sh) - for handling keyword arguments
  - [list](src/util/list.sh) - common list operations
  - [math](src/util/math.sh) - common math operations
  - [prof](src/util/prof.sh) - runtime profiling routines
  - [string](src/util/string.sh) - common string operations
  - [time](src/util/time.sh) - common time and date operations

You have the choice of loading an entire module, or select certain packages from them.

## Documentation

See the [manual](src/MANUAL.md) for an exhaustive list of functions defined in each package.

## Alternatives

There are a number of different bash libraries out there, including:

- [aks/bash-lib](https://github.com/aks/bash-lib)
- [cyberark/bash-lib](https://github.com/cyberark/bash-lib)
- [dylanaraps/pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)
- [jandob/rebash](https://github.com/jandob/rebash)
