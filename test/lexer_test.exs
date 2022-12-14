defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  setup_all do
    {:ok,
     tokens: [
       :int_keyword,
       :main_keyword,
       :open_paren,
       :close_paren,
       :open_brace,
       :return_keyword,
       {:constant, 2},
       :semicolon,
       :close_brace
     ],
     unary_ops_tokens: [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      :negation,
      :logical_negation,
      :bitwise_complement,
      {:constant, 2},
      :semicolon,
      :close_brace
    ],
    binary_ops1_tokens: [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :negation,
      {:constant, 2},
      :addition,
      {:constant, 3},
      :multiplication,
      {:constant, 4},
      :division,
      {:constant, 5},
      :semicolon,
      :close_brace
    ],
    binary_ops2_tokens: [
      :int_keyword,
      :main_keyword,
      :open_paren,
      :close_paren,
      :open_brace,
      :return_keyword,
      {:constant, 1},
      :and,
      {:constant, 2},
      :or,
      {:constant, 3},
      :equal,
      {:constant, 4},
      :not_equal,
      {:constant, 5},
      :less_than,
      {:constant, 6},
      :less_than_or_equal,
      {:constant, 7},
      :greater_than,
      {:constant, 8},
      :greater_than_or_equal,
      {:constant, 9},
      :semicolon,
      :close_brace
    ]
  }
  end

  test "return 2", state do
    code = """
      int main() {
        return 2;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "return 0", state do
    code = """
      int main() {
        return 0;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {:constant, 0} end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "multi_digit", state do
    code = """
      int main() {
        return 100;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    expected_result = List.update_at(state[:tokens], 6, fn _ -> {:constant, 100} end)
    assert Lexer.scan_words(s_code) == expected_result
  end

  test "new_lines", state do
    code = """
    int
    main
    (
    )
    {
    return
    2
    ;
    }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "no_newlines", state do
    code = """
    int main(){return 2;}
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "spaces", state do
    code = """
    int   main    (  )  {   return  2 ; }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:tokens]
  end

  test "elements separated just by spaces", state do
    assert Lexer.scan_words(["int", "main(){return", "2;}"]) == state[:tokens]
  end

  test "function name separated of function body", state do
    assert Lexer.scan_words(["int", "main()", "{return", "2;}"]) == state[:tokens]
  end

  test "everything is separated", state do
    assert Lexer.scan_words(["int", "main", "(", ")", "{", "return", "2", ";", "}"]) ==
             state[:tokens]
  end

  test "unary operators", state do
    code = """
      int main() {
        return -!~2;
      }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:unary_ops_tokens]
  end

  test "binary operators 1", state do
    code = """
      int main() {
        return 1 - 2 + 3 * 4 / 5;
      }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:binary_ops1_tokens]
  end

  test "binary operators 2", state do
    code = """
      int main() {
        return 1 && 2 || 3 == 4 != 5 < 6 <= 7 > 8 >= 9;
      }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == state[:binary_ops2_tokens]
  end

  # Invalid

  test "no space between int and main" do
    code = """
      intmain () {
        return 2;
      }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == {:lexing_error, :invalid_token, "Invalid token: intmain"}
  end

  test "no space between return and constant" do
    code = """
      int main() {
        return2;
      }
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == {:lexing_error, :invalid_token, "Invalid token: return2;"}
  end

  test "unknown token after function" do
    code = """
      int main() {
        return 2;
      } vfadsfga
    """

    s_code = Sanitizer.sanitize_source(code)

    assert Lexer.scan_words(s_code) == {:lexing_error, :invalid_token, "Invalid token: vfadsfga"}
  end
end
