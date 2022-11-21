defmodule SanitizerTest do
  use ExUnit.Case
  doctest Sanitizer

  test "no spaces" do
    code = """
      intmain(){return2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain(){return2;}"]
  end

  test "one space" do
    code = """
      intmain(){return 2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain(){return", "2;}"]
  end

  test "more spaces" do
    code = """
      int main() {return 2;}
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{return", "2;}"]
  end

  test "newline" do
    code = """
      intmain()
      {return2;}
    """
    assert Sanitizer.sanitize_source(code) == ["intmain()", "{return2;}"]
  end

  test "more newlines" do
    code = """
      int
      main()
      {return
      2;}
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{return", "2;}"]
  end

  test "newlines and spaces" do
    code = """
      int main() {
        return 2;
      }
    """
    assert Sanitizer.sanitize_source(code) == ["int", "main()", "{", "return", "2;", "}"]
  end
end
