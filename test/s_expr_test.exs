defmodule SExprTest do
  use ExUnit.Case
  doctest SExpr

  test "greets the world" do
    assert SExpr.hello() == :world
  end
end
