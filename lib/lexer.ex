defmodule Lexer do
  def scan_words(words) do
    tokens = Enum.flat_map(words, &lex_raw_tokens/1)
    result = Enum.reduce_while(tokens, [], fn x, acc ->
      case x do
        {:lexing_error, :invalid_token, _} -> {:halt, x}
        _ -> {:cont, acc ++ [x]}
      end
    end)
    result
  end

  def get_constant(program) do
    case Regex.run(~r/^\d+/, program) do
      [value] ->
        {{:constant, String.to_integer(value)}, String.trim_leading(program, value)}

      _ ->
        IO.puts("Invalid token: #{program}")
        {:lexing_error, :invalid_token, "Invalid token: #{program}"}
    end
  end

  def lex_raw_tokens(program) when program != "" do
    result =
      case program do
        "{" <> rest ->
          {:open_brace, rest}

        "}" <> rest ->
          {:close_brace, rest}

        "(" <> rest ->
          {:open_paren, rest}

        ")" <> rest ->
          {:close_paren, rest}

        ";" <> rest ->
          {:semicolon, rest}

        # Debe haber un espacio forzosamente despues de las palabras reservadas return e int.
        # Por lo tanto, el sanitizer debio de haber separado la cadena por el espacio.
        "return" ->
          {:return_keyword, ""}

        "int" ->
          {:int_keyword, ""}

        "main" <> rest ->
          {:main_keyword, rest}

        "~" <> rest ->
          {:bitwise_complement, rest}

        "-" <> rest ->
          {:negation, rest}

        "!=" <> rest ->
          {:not_equal, rest}

        "!" <> rest ->
          {:logical_negation, rest}

        "+" <> rest ->
          {:addition, rest}

        "*" <> rest ->
          {:multiplication, rest}

        "/" <> rest ->
          {:division, rest}

        "&&" <> rest ->
          {:and, rest}

        "||" <> rest ->
          {:or, rest}

        "==" <> rest ->
          {:equal, rest}

        "<=" <> rest ->
          {:less_than_or_equal, rest}

        "<" <> rest ->
          {:less_than, rest}

        ">=" <> rest ->
          {:greater_than_or_equal, rest}

        ">" <> rest ->
          {:greater_than, rest}

        _ ->
          get_constant(program)
      end

    case result do
      {:lexing_error, _, _} -> [result]
      {token, rest} ->
        remaining_tokens = lex_raw_tokens(rest)
        [token | remaining_tokens]
    end

  end

  def lex_raw_tokens(_program) do
    []
  end
end
