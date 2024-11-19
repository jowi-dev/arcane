defmodule Arcane.ParserTest do
  use ExUnit.Case
  doctest Arcane.Parser

  alias Arcane.Parser
  alias Arcane.Token

  test "if given a string, pass through" do
    str = "hello world"

    assert "hello world" = Parser.pass_through(str)
  end

  test "generates s_expression style AST" do
    tokens = [
      Token.int("1"),
      Token.plus(),
      Token.int("2")
    ]

    assert ["+", 1, 2] = Parser.parse_expression(tokens)
  end
end
