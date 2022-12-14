defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

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

  defp test_invalid(tokens, error_type) do
    {:parsing_error, out_error_type, _error_message} = Parser.parse_program(tokens)
    assert out_error_type == error_type
  end

  # Valid

  test "return 5 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:constant_ast]
  end

  test "return -5 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :negation,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:subtraction_ast]
  end

  test "return !5 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :logical_negation,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:logical_negation_ast]
  end

  test "return ~5 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :bitwise_complement,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:bitwise_complement_ast]
  end

  test "return 5 - 3 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :negation,
      {:constant, 3},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:subtraction_binop_ast]
  end

  test "return 5 not equal 3 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :not_equal,
      {:constant, 3},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:not_equal_ast]
  end

  test "return 5 + 3 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :addition,
      {:constant, 3},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:addition_ast]
  end

  test "return 5 * 3 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :multiplication,
      {:constant, 3},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:multiplication_ast]
  end

  test "return 5 / 3 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :division,
      {:constant, 3},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:division_ast]
  end

  test "return 1 and 1 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :and,
      {:constant, 1},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:and_ast]
  end

  test "return 1 or 0 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :or,
      {:constant, 0},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:or_ast]
  end

  test "return 5 equals 5 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :equal,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:equal_ast]
  end

  test "return 1 <= 2 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :less_than_or_equal,
      {:constant, 2},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:less_than_or_equal_ast]
  end

  test "return 1 < 2 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :less_than,
      {:constant, 2},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:less_than_ast]
  end

  test "return 2 >= 1 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 2},
      :greater_than_or_equal,
      {:constant, 1},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:greater_than_or_equal_ast]
  end

  test "return 2 > 1 AST", state do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 2},
      :greater_than,
      {:constant, 1},
      :semicolon,
      :close_brace
    ]

    assert Parser.parse_program(tokens) == state[:greater_than_ast]
  end

  # Invalid

  test "close paren missed" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :open_brace,
      :return_keyword,
      :logical_negation,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :close_paren_missed)
  end

  test "missing retval" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :constant_missed)
  end

  test "open brace missed" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :return_keyword,
      :bitwise_complement,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :open_brace_missed)
  end

  test "no semicolon on return statement" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :bitwise_complement,
      {:constant, 5},
      :close_brace
    ]

    test_invalid(tokens, :return_semicolon_missed)
  end

  test "main function missed" do
    tokens = [
      :int_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :bitwise_complement,
      {:constant, 5},
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :main_function_missed)
  end

  test "nested missing const" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :logical_negation,
      :bitwise_complement,
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :constant_missed)
  end

  test "wrong order" do
    tokens = [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 5},
      :bitwise_complement,
      :semicolon,
      :close_brace
    ]

    test_invalid(tokens, :return_semicolon_missed)
  end
end
