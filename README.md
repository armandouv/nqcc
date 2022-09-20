# Nqcc

**This is a nice small C subset compiler implemented in Elixir.**

## Installation

1. git clone https://github.com/hiphoox/c321-turingmachine 
2. mix escript.build

## Using

- ./nqcc file_name.c
- ./nqcc --help

## Examples
- $ nqcc ./examples/return_2.c

## Testing

### test all
```
./test_compiler.sh /path/to/your/compiler
```

### test specific stages
To test stage 1 and stage 3,
```
./test/test_compiler.sh /path/to/your/compiler 1 3
```
To test from stage 1 to stage 6,
```
./test/test_compiler.sh /path/to/your/compiler `seq 1 6`
```

In order to use this script, your compiler needs to follow this spec:

1. It can be invoked from the command line, taking only a C source file as an argument, e.g.: `./YOUR_COMPILER /path/to/program.c`

2. When passed `program.c`, it generates executable `program` in the same directory.

3. It doesn’t generate assembly or an executable if parsing fails (this is what the test script checks for invalid test programs).

The script doesn’t check whether your compiler outputs sensible error messages, but you can use the invalid test programs to test that manually.
