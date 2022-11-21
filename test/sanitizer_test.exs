defmodule SanitizerTest do
  use ExUnit.Case
  doctest Sanitizer

  test "no spaces", state do
    code = """
      intmain(){return2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain(){return2;}"]
  end

  test "one space", state do
    code = """
      intmain(){return 2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain(){return", "2;}"]
  end

  test "more spaces", state do
    code = """
      int main() {return 2;}
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{return", "2;}"]
  end

  test "newline", state do
    code = """
      intmain()
      {return2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain()", "{return2;}"]
  end

  test "more newlines", state do
    code = """
      int
      main()
      {return
      2;}
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{return", "2;}"]
  end

  test "newlines and spaces", state do
    code = """
      int main() {
        return 2;
      }
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{", "return", "2;", "}"]
  end
end
