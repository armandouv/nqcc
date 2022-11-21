defmodule LinkerTest do
  use ExUnit.Case
  doctest Linker

  setup_all do
    {:ok,
      constant_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :constant, value: 5}
          }
        }
      },

      subtraction_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :unary_operator, value: :negation,
              left_node: %AST{node_name: :constant, value: 5}
            }
          }
        }
      },

      logical_negation_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :unary_operator, value: :logical_negation,
              left_node: %AST{node_name: :constant, value: 5}
            }
          }
        }
      },

      bitwise_complement_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :unary_operator, value: :bitwise_complement,
              left_node: %AST{node_name: :constant, value: 5}
            }
          }
        }
      }
    }

  end

  defp test_valid(compiled_code) do
    link_status = Nqcc.link_code("my_test.c", compiled_code)
    assert link_status == 0

    File.rm!("./my_test")
  end

  defp test_invalid(compiled_code) do
    link_status = Nqcc.link_code("my_test.c", compiled_code)
    assert link_status != 0
  end


  # Valid

  test "return 5" do
    compiled_code =
    """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        ret
    """

    test_valid(compiled_code)
  end

  test "return -5" do
    compiled_code =
    """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        neg     %eax
        ret
    """

    test_valid(compiled_code)
  end

  test "return !5" do
    compiled_code =
    """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        cmpl   $0, %eax
        movl   $0, %eax
        sete   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return ~5" do
    compiled_code =
    """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        not     %eax
        ret
    """

    test_valid(compiled_code)
  end


  # Invalid

  test "no headers" do
    compiled_code =
    """
    main:                    ## @main
        movl    $5, %eax
        ret
    """

    test_invalid(compiled_code)
  end

  test "wrong function naming" do
    compiled_code =
    """
        .section        .text
        .p2align        4, 0x90
        .globl  _main         ## -- Begin function main
    _main:                    ## @main
        movl    $5, %eax
        ret
    """

    test_invalid(compiled_code)
  end

  test "wrong headers" do
    compiled_code =
    """
        .section        __TEXT,__text,regular,pure_instructions
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        ret
    """

    test_invalid(compiled_code)
  end
end
