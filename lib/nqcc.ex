defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "help" => "Prints this help",
    "sn" => "Prints sanitizer output",
    "l" => "Prints scanner output",
    "p" => "Prints parser output",
    "s" => "Prints code generator output"
  }

  def main(args) do
    args
    |> parse_args
    |> process_args
  end

  def parse_args(args) do
    OptionParser.parse(args, strict: [help: :boolean, l: :boolean, p: :boolean, s: :boolean, sn: :boolean])
  end

  defp process_args({[help: true], _, _}) do
    print_help_message()
  end

  defp process_args({parsed, [file_name], _}) do
    flags = for {flag_name, _} <- parsed, into: MapSet.new, do: flag_name
    compile_file(file_name, flags)
  end

  def inspect_output(output, flags, target_flag, label) when is_binary(output) do
    if target_flag in flags do
      IO.puts(label <> ":")
      IO.puts(output)
    end
    output
  end

  def inspect_output(output, flags, target_flag, label) do
    if target_flag in flags do
      IO.inspect(output, label: label)
    end
    output
  end

  defp compile_file(file_path, flags) do
    IO.puts("Compiling file: " <> file_path)
    assembly_path = String.replace_trailing(file_path, ".c", ".s")

    File.read!(file_path)
    |> Sanitizer.sanitize_source()
    |> inspect_output(flags, :sn, "\nSanitizer output")
    |> Lexer.scan_words()
    |> inspect_output(flags, :l, "\nLexer output")
    |> Parser.parse_program()
    |> inspect_output(flags, :p, "\nParser output")
    |> CodeGenerator.generate_code()
    |> inspect_output(flags, :s, "\nCode generator output")
    |> Linker.generate_binary(assembly_path)
  end

  defp print_help_message do
    IO.puts("\nnqcc --help file_name \n")

    IO.puts("\nThe compiler supports the following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
