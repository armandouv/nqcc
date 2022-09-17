defmodule Nqcc do
  @moduledoc """
  Documentation for Nqcc.
  """
  @commands %{
    "help" => "Prints this help"
  }

  @spec main([binary]) :: :ok | list
  def main(args) do
    args
    |> parse_args
    |> process_args
  end

  def parse_args(args) do
    OptionParser.parse(args, switches: [help: :boolean])
  end

  defp process_args({[help: true], _, _}) do
    print_help_message()
  end

  defp process_args({_, [file_name], _}) do
    compile_file(file_name)
  end

  defp compile_file(file_path) do
    IO.puts("Compiling file: " <> file_path)
  end

  defp print_help_message do
    IO.puts("\nqcc --help file_name \n")
    IO.puts("\nThe compiler supports following options:\n")

    @commands
    |> Enum.map(fn {command, description} -> IO.puts("  #{command} - #{description}") end)
  end
end
