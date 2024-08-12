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

### Bootstrap (recommended)

Download and run the interactive bootstrap script to install the latest release. The script will allow you to enter a directory of your choice or you can select from prepopulated locations.

```bash
bash <(curl -sSL tomocafe.github.io/bash-boost/bootstrap.sh)
```

You can rerun this at any time to update an exsting installation.

### From release tarball

Download and extract the [latest release](https://github.com/tomocafe/bash-boost/releases), then follow the instructions in the Usage section.

### From `git`

Clone this repository and run `make`. For manpage generation, `perl` and `pandoc` are required.

## Usage

Source the `bash-boost.sh` script and use `bb_load` to load modules and/or packages

```bash
source /path/to/bash-boost/latest/bash-boost.sh

bb_load MODULE      # e.g. cli
bb_load MODULE/PKG  # e.g. cli/arg
```

Alternatively, you can list modules and packages to load by argument when sourcing `bash-boost.sh`:

```bash
source /path/to/bash-boost/latest/bash-boost.sh MODULE MODULE/PKG ...
```

If you want to distribute bash-boost as a single file, you can use `bash-boost-portable.sh` and all modules and packages will be available for use. Please use proper attribution if distributing bash-boost. See [LICENSE](LICENSE) for details.

```bash
source /path/to/bash-boost-portable.sh
```

You may also want to add the included scripts and manpages to your path lists:

```bash
bb_load util/env # for bb_appendpathuniq
bb_appendpathuniq PATH "$BB_ROOT/bin"
bb_appendpathuniq MANPATH "$BB_ROOT/man"
```

## Organization

bash-boost consists of the following _modules_, each with different _packages_

- **cli** - for command-line (script) use
  - [arg](src/MANUAL.md#package-cliarg) - for parsing command line arguments
  - [color](src/MANUAL.md#package-clicolor) - for printing text in color
  - [input](src/MANUAL.md#package-cliinput) - for handling user input
  - [msg](src/MANUAL.md#package-climsg) - for messaging and logging
  - [progress](src/MANUAL.md#package-cliprogress) - for creating progress bars
- **interactive** - for interactive use
  - [cmd](src/MANUAL.md#package-interactivecmd) - miscellaneous interactive commands
  - [prompt](src/MANUAL.md#package-interactiveprompt) - dynamic shell prompt
  - [bookmark](src/MANUAL.md#package-interactivebookmark) - directory bookmarking system
- **util** - general purpose routines
  - [env](src/MANUAL.md#package-utilenv) - for checking and setting environment variables
  - [file](src/MANUAL.md#package-utilfile) - file and filesystem related operations
  - [kwargs](src/MANUAL.md#package-utilkwargs) - for handling keyword arguments
  - [list](src/MANUAL.md#package-utillist) - common list operations
  - [math](src/MANUAL.md#package-utilmath) - common math operations
  - [prof](src/MANUAL.md#package-utilprof) - runtime profiling routines
  - [string](src/MANUAL.md#package-utilstring) - common string operations
  - [time](src/MANUAL.md#package-utiltime) - common time and date operations
  - [rand](src/MANUAL.md#package-utilrand) - random number and string generation

You have the choice of loading an entire module, or selecting certain packages from them.

## Documentation

Consult the [full manual](src/MANUAL.md) for an exhaustive list of functions defined in each package.

## Versioning

This project follows [semantic versioning](https://semver.org/). Any breaking changes must be made in a new major release. New functions are introduced in minor releases. Patch releases only include fixes to existing functions. No documented feature should be regressed in a minor or patch release.

## Alternatives

There are a number of different bash libraries out there, including:

- [aks/bash-lib](https://github.com/aks/bash-lib)
- [cyberark/bash-lib](https://github.com/cyberark/bash-lib)
- [dylanaraps/pure-bash-bible](https://github.com/dylanaraps/pure-bash-bible)
- [jandob/rebash](https://github.com/jandob/rebash)
