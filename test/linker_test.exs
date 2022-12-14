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
      },

      subtraction_binop_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :negation,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 3}
            }
          }
        }
      },

      not_equal_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :not_equal,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 3}
            }
          }
        }
      },

      addition_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :addition,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 3}
            }
          }
        }
      },

      multiplication_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :multiplication,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 3}
            }
          }
        }
      },

      division_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :division,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 3}
            }
          }
        }
      },

      and_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :and,
              left_node: %AST{node_name: :constant, value: 1},
              right_node: %AST{node_name: :constant, value: 1}
            }
          }
        }
      },

      or_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :or,
              left_node: %AST{node_name: :constant, value: 1},
              right_node: %AST{node_name: :constant, value: 0}
            }
          }
        }
      },

      equal_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :equal,
              left_node: %AST{node_name: :constant, value: 5},
              right_node: %AST{node_name: :constant, value: 5}
            }
          }
        }
      },

      less_than_or_equal_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :less_than_or_equal,
              left_node: %AST{node_name: :constant, value: 1},
              right_node: %AST{node_name: :constant, value: 2}
            }
          }
        }
      },

      less_than_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :less_than,
              left_node: %AST{node_name: :constant, value: 1},
              right_node: %AST{node_name: :constant, value: 2}
            }
          }
        }
      },

      greater_than_or_equal_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :greater_than_or_equal,
              left_node: %AST{node_name: :constant, value: 2},
              right_node: %AST{node_name: :constant, value: 1}
            }
          }
        }
      },

      greater_than_ast: %AST{node_name: :program,
        left_node: %AST{node_name: :function, value: :main,
          left_node: %AST{node_name: :return, left_node:
            %AST{node_name: :binary_operator, value: :greater_than,
              left_node: %AST{node_name: :constant, value: 2},
              right_node: %AST{node_name: :constant, value: 1}
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

  test "return 5 - 3", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $3, %eax
        push   %rax
        movl    $5, %eax
        pop    %rcx
        subl   %ecx, %eax
        ret
    """

    test_valid(compiled_code)
  end

  test "5 not equal 3", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        push   %rax
        movl    $3, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setne   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return 5 + 3", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        push   %rax
        movl    $3, %eax
        pop    %rcx
        addl   %ecx, %eax
        ret
    """

    test_valid(compiled_code)
  end

  test "return 5 * 3", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        push   %rax
        movl    $3, %eax
        pop    %rcx
        imul   %ecx, %eax
        ret
    """

    test_valid(compiled_code)
  end

  test "return 5 / 3", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $3, %eax
        push   %rax
        movl    $5, %eax
        cdq
        pop    %rcx
        idivl   %ecx
        ret
    """

    test_valid(compiled_code)
  end

  test "return 1 and 1", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $1, %eax
        cmpl $0, %eax
        jne clause0
        jmp end0
    clause0:
        movl    $1, %eax
        cmpl $0, %eax
        movl $0, %eax
        setne %al
    end0:
        ret
    """

    test_valid(compiled_code)
  end

  test "return 1 or 0", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $1, %eax
        cmpl $0, %eax
        je clause0
        movl $1, %eax
        jmp end0
    clause0:
        movl    $0, %eax
        cmpl $0, %eax
        movl $0, %eax
        setne %al
    end0:
        ret
    """

    test_valid(compiled_code)
  end

  test "return 5 equals 5", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $5, %eax
        push   %rax
        movl    $5, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        sete   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return 1 <= 2", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $1, %eax
        push   %rax
        movl    $2, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setle   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return 1 < 2", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $1, %eax
        push   %rax
        movl    $2, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setl   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return 2 >= 1", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $2, %eax
        push   %rax
        movl    $1, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setge   %al
        ret
    """

    test_valid(compiled_code)
  end

  test "return 2 > 1", state do
    compiled_code =
      """
        .section        .text
        .p2align        4, 0x90
        .globl  main         ## -- Begin function main
    main:                    ## @main
        movl    $2, %eax
        push   %rax
        movl    $1, %eax
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setg   %al
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
