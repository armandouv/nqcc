defmodule Lexer do
  def scan_words(words) do
    Enum.flat_map(words, &lex_raw_tokens/1)
  end

  def get_constant(program) do
    case Regex.run(~r/^\d+/, program) do
      [value] ->
        {{:constant, String.to_integer(value)}, String.trim_leading(program, value)}

      _ ->
        IO.puts("Invalid token: #{program}")
        {:error, ""}
    end
  end

  def lex_raw_tokens(program) when program != "" do
    {token, rest} =
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

        _ ->
          get_constant(program)
      end

    if token != :error do
      remaining_tokens = lex_raw_tokens(rest)
      [token | remaining_tokens]
    else
      [:error]
    end
  end

  def lex_raw_tokens(_program) do
    []
  end
end
