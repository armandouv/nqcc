# Nqcc

**This is a nice small C subset compiler implemented in Elixir.**

## Installation

1. `git clone https://github.com/hiphoox/c321-turingmachine`
2. `mix escript.build`

## How to compile a C program?

`./nqcc file_name.c`

## Help

- Prints help options: `./nqcc file_name.c --help`
- Prints all compiling stages output and compiles the specified file: `./nqcc file_name.c --A`
- Prints scanner output: `./nqcc file_name.c --l`
- Prints parser output: `./nqcc file_name.c --p`
- Prints code generator: output `./nqcc file_name.c --s`
- Prints sanitizer output: `./nqcc file_name.c --sn`

## Examples
- `$ nqcc ./examples/return_2.c`
- `$ nqcc ./examples/return_2.c --A`
- `$ nqcc ./examples/return_2.c --sn`

## Testing

`mix test`
