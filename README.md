# bash-boost

bash-boost is a set of library functions for bash, useful for both scripting and interactive use. It draws inspiration from the [Boost](https://boost.org) C++ libraries.

## Philosophy

- Prefer pure-bash solutions
- Don't reimplement existing bash features, complement them
- Functions should have a single purpose, without complicated options
- Avoid cluttering the user's environment

For examples and further details, see [CONTRIBUTING.md](CONTRIBUTING.md)

## Requirements

`bash` version 4.2 or later.

This has only been tested for Linux. YMMV for other platforms.

## Installation

### From release tarball (recommended)

Download and extract the [latest release](https://github.com/tomocafe/bash-boost/releases), then follow the instructions in the Usage section.

### From `git`

Clone this repository and run `make`. For manual generation, `perl` and `pandoc` are required.

## Usage

Source the `bash-boost.sh` script and use `bb_load` to load modules and/or packages

```bash
source /path/to/bash-boost.sh

bb_load MODULE      # e.g. cli
bb_load MODULE/PKG  # e.g. cli/arg
```

Alternatively, you can list modules and packages to load by argument when sourcing `bash-boost.sh`:

```bash
source /path/to/bash-boost.sh MODULE MODULE/PKG ...
```

If you want to distribute bash-boost as a single file, you can use `bash-boost-portable.sh` and all modules and packages will be available for use. Please use proper attribution if distributing bash-boost. See [LICENSE](LICENSE) for details.

```bash
source /path/to/bash-boost-portable.sh
```

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

## Versioning

This project follows [semantic versioning](https://semver.org/). Any breaking changes must be made in a new major release. New functions are introduced in minor releases. Patch releases only include fixes to existing functions. No documented feature should be regressed in a minor or patch release.

## Alternatives

There are a number of different bash libraries out there, including:

- [aks/bash-lib](https://github.com/aks/bash-lib)
- [cyberark/bash-lib](https://github.com/cyberark/bash-lib)
- [dylanaraps/pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)
- [jandob/rebash](https://github.com/jandob/rebash)
