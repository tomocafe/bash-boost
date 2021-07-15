# bash-boost

bash-boost is a set of library functions for bash, useful for both scripting and interactive use. It draws inspiration from the [Boost](https://boost.org) C++ libraries.

## Philosophy

- Always prefer pure-bash solutions

## Requirements

`bash` 4.x or later

## Installation

TO DO

## Organization

bash-boost consists of the following _modules_, each with different _packages_

- [**cli**](src/cli) - for command-line (script) use
- [**interactive**](src/interactive) - for interactive use
- [**util**](src/util) - general purpose routines

You have the choice of loading an entire module, or select certain packages from them.

## Documentation

See the [manual](src/MANUAL.md) for an exhaustive list of functions defined in each package.
