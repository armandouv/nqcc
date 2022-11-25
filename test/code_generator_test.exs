defmodule CodeGeneratorTest do
  use ExUnit.Case
  doctest CodeGenerator

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

  test "return 5", state do
    assert CodeGenerator.generate_code(state[:constant_ast]) ==
    """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        ret
    """
  end

  test "return -5", state do
    assert CodeGenerator.generate_code(state[:subtraction_ast]) ==
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        neg     %eax
        ret
    """
  end

  test "return !5", state do
    assert CodeGenerator.generate_code(state[:logical_negation_ast]) ==
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
  end

  test "return ~5", state do
    assert CodeGenerator.generate_code(state[:bitwise_complement_ast]) ==
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        not     %eax
        ret
    """
  end

end
