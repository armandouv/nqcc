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

    # Instead of returning a value, print it so that it can be checked (if returned as a status code it will be restricted
    # to an 8 bit unsigned integer)
    compiled_code = """
      .section	.rodata
      .LC0:
        .string	"%d"
      """
      <> String.slice(compiled_code, 0..-5) <>
      """
        pushq	%rbp
        movq	%rsp, %rbp
        movl	%eax, %esi
        leaq	.LC0(%rip), %rdi
        movl	$0, %eax
        call	printf@PLT
        movl	$0, %eax
        popq	%rbp
        ret
      """

    link_status = Nqcc.link_code("my_test.c", compiled_code)
    assert link_status == 0

    executable_path = "./my_test"
    {output, exit_status} = System.shell(executable_path)
    File.rm!(executable_path)
    assert exit_status == 0;
    assert String.to_integer(output) == expected_return_val
  end

  defp test_invalid(code, error_stage, error_type) do
    {out_error_stage, out_error_type, _error_message} = Nqcc.compile_code(code, [])
    assert out_error_stage == error_stage
    assert out_error_type == error_type
  end


  ## Stage 1

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


  ## Stage 2

  # Valid

  test "bitwise" do
    code = """
      int main() {
        return ~12;
      }
    """

    test_valid(code, -13)
  end

  test "bitwise zero" do
    code = """
      int main() {
        return ~0;
      }
    """

    test_valid(code, -1)
  end

  test "neg" do
    code = """
      int main() {
        return -5;
      }
    """

    test_valid(code, -5)
  end

  test "nested ops" do
    code = """
      int main() {
        return !-3;
      }
    """

    test_valid(code, 0)
  end

  test "nested ops 2" do
    code = """
      int main() {
        return -~0;
      }
    """

    test_valid(code, 1)
  end

  test "not 5" do
    code = """
      int main() {
        return !5;
      }
    """

    test_valid(code, 0)
  end

  test "not 0" do
    code = """
      int main() {
        return !0;
      }
    """

    test_valid(code, 1)
  end

  # Invalid

  test "missing const" do
    code = """
      int main() {
        return !;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "missing semicolon" do
    code = """
      int main() {
        return !5
      }
    """

    test_invalid(code, :parsing_error, :return_semicolon_missed)
  end

  test "nested missing const" do
    code = """
      int main() {
        return !~;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "wrong order" do
    code = """
      int main() {
        return 4-;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end


  ## Stage 3

  # Valid

  test "add" do
    code = """
      int main() {
        return 1 + 2;
      }
    """

    test_valid(code, 3)
  end

  test "associativity" do
    code = """
      int main() {
        return 1 - 2 - 3;
      }
    """

    test_valid(code, -4)
  end

  test "associativity 2" do
    code = """
      int main() {
        return 6 / 3 / 2;
      }
    """

    test_valid(code, 1)
  end

  test "div" do
    code = """
      int main() {
        return 4 / 2;
      }
    """

    test_valid(code, 2)
  end

  test "div neg" do
    code = """
      int main() {
        return (-12) / 5;
      }
    """

    test_valid(code, -2)
  end

  test "div neg no parens" do
    code = """
      int main() {
        return -12 / 5;
      }
    """

    test_valid(code, -2)
  end

  test "div neg outside parens" do
    code = """
      int main() {
        return -(12 / 5);
      }
    """

    test_valid(code, -2)
  end

  test "mult" do
    code = """
      int main() {
        return 2 * 3;
      }
    """

    test_valid(code, 6)
  end

  test "parens" do
    code = """
      int main() {
        return 2 * (3 + 4);
      }
    """

    test_valid(code, 14)
  end

  test "precedence" do
    code = """
      int main() {
        return 2 + 3 * 4;
      }
    """

    test_valid(code, 14)
  end

  test "sub" do
    code = """
      int main() {
        return 1 - 2;
      }
    """

    test_valid(code, -1)
  end

  test "sub neg" do
    code = """
      int main() {
        return 2- -1;
      }
    """

    test_valid(code, 3)
  end

  test "unop add" do
    code = """
      int main() {
        return ~2 + 3;
      }
    """

    test_valid(code, 0)
  end

  test "unop parens" do
    code = """
      int main() {
        return ~(1 + 1);
      }
    """

    test_valid(code, -3)
  end

  # Invalid

  test "malformed paren" do
    code = """
      int main() {
        return 2 (- 3);
      }
    """

    # If there's no operator after constant, a semicolon is expected.
    test_invalid(code, :parsing_error, :return_semicolon_missed)
  end

  test "missing first op" do
    code = """
      int main() {
        return /3;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "missing second op" do
    code = """
      int main() {
        return 1 + ;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "no semicolon binary op" do
    code = """
      int main() {
        return 2*2
      }
    """

    test_invalid(code, :parsing_error, :return_semicolon_missed)
  end


  ## Stage 4

  # Valid

  test "and false" do
    code = """
      int main() {
        return 1 && 0;
      }
    """

    test_valid(code, 0)
  end

  test "and true" do
    code = """
      int main() {
        return 1 && -1;
      }
    """

    test_valid(code, 1)
  end

  test "eq false" do
    code = """
      int main() {
        return 1 == 2;
      }
    """

    test_valid(code, 0)
  end

  test "eq true" do
    code = """
      int main() {
        return 1 == 1;
      }
    """

    test_valid(code, 1)
  end

  test "ge false" do
    code = """
      int main() {
        return 1 >= 2;
      }
    """

    test_valid(code, 0)
  end

  test "ge true" do
    code = """
      int main() {
        return 3 >= 2;
      }
    """

    test_valid(code, 1)
  end

  test "ge true 2" do
    code = """
      int main() {
        return 2 >= 2;
      }
    """

    test_valid(code, 1)
  end

  test "gt false" do
    code = """
      int main() {
        return 1 > 2;
      }
    """

    test_valid(code, 0)
  end

  test "gt true" do
    code = """
      int main() {
        return 5 > 2;
      }
    """

    test_valid(code, 1)
  end

  test "le false" do
    code = """
      int main() {
        return 3 <= 2;
      }
    """

    test_valid(code, 0)
  end

  test "le true" do
    code = """
      int main() {
        return 1 <= 2;
      }
    """

    test_valid(code, 1)
  end

  test "le true 2" do
    code = """
      int main() {
        return 1 <= 1;
      }
    """

    test_valid(code, 1)
  end

  test "lt false" do
    code = """
      int main() {
        return 7 < 2;
      }
    """

    test_valid(code, 0)
  end

  test "lt true" do
    code = """
      int main() {
        return 1 < 2;
      }
    """

    test_valid(code, 1)
  end

  test "ne false" do
    code = """
      int main() {
        return 0 != 0;
      }
    """

    test_valid(code, 0)
  end

  test "ne true" do
    code = """
      int main() {
        return 1 != 0;
      }
    """

    test_valid(code, 1)
  end

  test "or false" do
    code = """
      int main() {
        return 0 || 0;
      }
    """

    test_valid(code, 0)
  end

  test "or true" do
    code = """
      int main() {
        return 1 || 0;
      }
    """

    test_valid(code, 1)
  end

  test "precedence binops2" do
    code = """
      int main() {
        return 1 || 0 && 2;
      }
    """

    test_valid(code, 1)
  end

  test "precedence binops2 2" do
    code = """
      int main() {
        return (1 || 0) && 0;
      }
    """

    test_valid(code, 0)
  end

  test "precedence binops2 3" do
    code = """
      int main() {
        return 2 == 2 > 0;
      }
    """

    test_valid(code, 0)
  end

  test "precedence binops2 4" do
    code = """
      int main() {
        return 2 == 2 || 0;
      }
    """

    test_valid(code, 1)
  end

  # TODO: Add short circuit tests

  # Invalid

  test "missing first op binops2" do
    code = """
      int main() {
        return <= 2;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "missing mid op binops2" do
    code = """
      int main() {
        return 1 < > 3;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "missing second op binops2" do
    code = """
      int main() {
        return 2 && ;
      }
    """

    test_invalid(code, :parsing_error, :constant_missed)
  end

  test "missing semicolon binops2" do
    code = """
      int main() {
        return 1 || 2
      }
    """

    test_invalid(code, :parsing_error, :return_semicolon_missed)
  end

end
