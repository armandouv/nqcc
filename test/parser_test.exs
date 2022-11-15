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
