defmodule SExpr.Compiler.CompilerFrontendTest do 
  use ExUnit.Case
  doctest SExpr.Compiler.CompilerFrontend

  alias SExpr.Compiler.CompilerFrontend

  test "simple add example" do 
    assert [:+, 1, 2] = CompilerFrontend.parse("{+, 1, 2}")
  end

  test "addition - bigger numbers" do 
    assert [:+, 100, 2543] = CompilerFrontend.parse("{+, 100, 2543}")
  end
end
