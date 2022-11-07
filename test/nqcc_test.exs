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

  defp test_invalid(code, error_stage, error_type) do
    {out_error_stage, out_error_type, _error_message} = Nqcc.compile_code(code, [])
    assert out_error_stage == error_stage
    assert out_error_type == error_type
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

  test "close paren missed" do
    code = """
      int main( {
        return 0;
      }
    """

    test_invalid(code, :parsing_error, :close_paren_missed)
  end

  test "open paren missed" do
    code = """
      int main ) {
        return 0;
      }
    """

    test_invalid(code, :parsing_error, :open_paren_missed)
  end

  test "missing retval" do
    code = """
      int main() {
        return ;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "open brace missed" do
    code = """
      int main()
        return 0;
      }
    """

    test_invalid(code, :parsing_error, :open_brace_missed)
  end

  test "close brace missed" do
    code = """
      int main() {
        return 0;

    """

    test_invalid(code, :parsing_error, :close_brace_missed)
  end

  test "no semicolon on return statement" do
    code = """
      int main() {
        return 0
      }
    """

    test_invalid(code, :parsing_error, :return_semicolon_missed)
  end

  test "no space on return statement" do
    code = """
      int main() {
        return0;
      }
    """

    test_invalid(code, :lexing_error, :invalid_token)
  end

  test "no space after int keyword" do
    code = """
      intmain() {
        return 0;
      }
    """

    test_invalid(code, :lexing_error, :invalid_token)
  end

  test "wrong case" do
    code = """
      int main() {
        RETURN 0;
      }
    """

    test_invalid(code, :lexing_error, :invalid_token)
  end

  test "invalid token after function end" do
    code = """
      int main() {
        return 0;
      }fads
    """

    test_invalid(code, :lexing_error, :invalid_token)
  end

  test "valid token after function end" do
    code = """
      int main() {
        return 0;
      }432
    """

    test_invalid(code, :parsing_error, :elements_after_end)
  end

  test "main function missed" do
    code = """
      int () {
        return 0;
      }
    """

    test_invalid(code, :parsing_error, :main_function_missed)
  end

  test "return type value missed" do
    code = """
      main() {
        return 0;
      }
    """

    test_invalid(code, :parsing_error, :return_type_missed)
  end

  test "return keyword missed" do
    code = """
      int main() {
        0;
      }
    """

    test_invalid(code, :parsing_error, :return_missed)
  end

end
