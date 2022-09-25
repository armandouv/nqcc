defmodule NqccTest do
  use ExUnit.Case
  doctest Nqcc

  # Flags test cases

  defp flag_does_not_generate_binary(flag) do
    test_executable_path = "./examples/return_2"
    test_source_path = test_executable_path <> ".c"

    s_code = Nqcc.main([test_source_path, "--" <> flag])
    assert s_code == :nil

    {status, reason} = File.stat(test_executable_path)
    assert status == :error and reason == :enoent
  end

  defp flag_generates_binary(flag) do
    test_executable_path = "./examples/return_100"
    test_source_path = test_executable_path <> ".c"

    s_code = Nqcc.main([test_source_path, "--" <> flag])
    assert s_code == 0

    {status, _} = File.stat(test_executable_path)
    assert status == :ok
    File.rm!(test_executable_path)
  end

  test "A flag generates binary" do
    flag_generates_binary("A")
  end

  test "help flag does not generate binary" do
    flag_does_not_generate_binary("help")
  end

  test "sn flag does not generate binary" do
    flag_does_not_generate_binary("sn")
  end

  test "l flag does not generate binary" do
    flag_does_not_generate_binary("l")
  end

  test "p flag does not generate binary" do
    flag_does_not_generate_binary("p")
  end

  test "s flag does not generate binary" do
    flag_does_not_generate_binary("s")
  end


  # Compilation test cases

  defp test_valid(code, expected_return_val) do
    compiled_code = Nqcc.compile_code(code, [])
    assert compiled_code != :error

    link_status = Nqcc.link_code("my_test.c", compiled_code)
    assert link_status == 0

    executable_path = "./my_test"
    {_, return_val} = System.shell(executable_path)
    File.rm!(executable_path)
    assert return_val == expected_return_val;
  end

  defp test_invalid(code) do
    compiled_code = Nqcc.compile_code(code, [])
    assert compiled_code == :error
  end

  # Valid

  test "multi-digit" do
    code = """
      int main() {
        return 100;
      }
    """

    test_valid(code, 100)
  end

  test "newlines" do
    code = """

      int
      main
      (
      )
      {
      return
      0
      ;
      }
    """

    test_valid(code, 0)
  end

  test "no newlines" do
    code = "int main(){return 0;}"
    test_valid(code, 0)
  end

  test "return 0" do
    code = """
      int main() {
        return 0;
      }
    """
    test_valid(code, 0)
  end

  test "return 2" do
    code = """
      int main() {
        return 2;
      }
    """
    test_valid(code, 2)
  end

  test "spaces" do
    code = "   int   main    (  )  {   return  0 ; }"
    test_valid(code, 0)
  end


  # Invalid

  test "missing paren" do
    code = """
      int main( {
        return 0;
      }
    """

    test_invalid(code)
  end

  test "missing retval" do
    code = """
      int main() {
        return;
      }
    """

    test_invalid(code)
  end

  test "no brace" do
    code = """
      int main() {
        return 0;

    """

    test_invalid(code)
  end

  test "no semicolon" do
    code = """
      int main() {
        return 0
      }
    """

    test_invalid(code)
  end

  test "no space on return statement" do
    code = """
      int main() {
        return0;
      }
    """

    test_invalid(code)
  end

  test "no space after int keyword" do
    code = """
      intmain() {
        return 0;
      }
    """

    test_invalid(code)
  end

  test "wrong case" do
    code = """
      int main() {
        RETURN 0;
      }
    """

    test_invalid(code)
  end

end
