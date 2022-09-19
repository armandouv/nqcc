# Nqcc

**This is the first part of small C subset compiler implemented in Elixir.**

## Installation

1. git clone https://github.com/hiphoox/c321-turingmachine 
2. mix escript.build

## How to compile Elixir scripts?

1. mix escript.build

## How to compile C program?

- mix escript.build 
- ./nqcc file_name.c

## Help

- Prints help options  ./nqcc file_name.c --help
- Prints all compiling stages output ./nqcc file_name.c --A 
- Prints scanner output ./nqcc file_name.c --l
- Prints parser output ./nqcc file_name.c --p
- Prints code generator output ./nqcc file_name.c --s
- Prints sanitizer output ./nqcc file_name.c --sn

## Examples
- $ nqcc ./examples/return_2.c
- $ nqcc ./examples/return_2.c --A
- $ nqcc ./examples/return_2.c --sn