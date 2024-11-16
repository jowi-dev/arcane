defmodule SExpr.Compiler.CompilerFrontendTest do
  use ExUnit.Case
  doctest SExpr.Compiler.CompilerFrontend

  alias SExpr.Compiler.CompilerFrontend

  test "simple add example" do
    assert [:+, 1, 2] = CompilerFrontend.parse("{+ 1 2}")
  end

  test "addition - bigger numbers" do
    assert [:+, 100, 2543] = CompilerFrontend.parse("{+ 100 2543}")
  end

  test "three param function" do
    assert [:yeet, 13, 37, 69] = CompilerFrontend.parse("{yeet 13 37 69}")
  end

  test "nested calls" do
    assert [:yeet, [:+, 1, 2], 69] = CompilerFrontend.parse("{yeet {+ 1 2} 69}")
  end

  test "double nested calls" do
    assert [:yeet, [:+, 1, 2], [:-, 22, 20]] = CompilerFrontend.parse("{yeet {+ 1 2} {- 22 20}}")
  end

  test "three layer nesting - A" do
    assert [:yeet, [:+, [:*, 3, 5], 2], [:-, 22, 20]] =
             CompilerFrontend.parse("{yeet {+ {* 3 5} 2} {- 22 20}}")
  end
end
