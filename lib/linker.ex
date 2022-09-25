defmodule Linker do
  def generate_binary(assembler, assembly_path) do
    assembly_file_name = Path.basename(assembly_path)
    binary_file_name = Path.basename(assembly_path, ".s")
    output_dir_name = Path.dirname(assembly_path)
    assembly_path = output_dir_name <> "/" <> assembly_file_name

    File.write!(assembly_path, assembler)
    {_, exit_status} = System.cmd("gcc", [assembly_file_name, "-o#{binary_file_name}"], cd: output_dir_name)
    File.rm!(assembly_path)

    exit_status
  end
end
