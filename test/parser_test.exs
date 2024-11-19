defmodule Arcane.ParserTest do
  use ExUnit.Case
  doctest Arcane.Parser

  alias Arcane.Parser
  alias Arcane.Token

  test "if given a string, pass through" do
    str = "hello world"

    assert "hello world" = Parser.pass_through(str)
  end

  test "parses an add statement" do
    tokens = [
      Token.int("1"),
      Token.plus(),
      Token.int("2")
    ]

    assert ["+", [1, 2]] = Parser.parse_expression(tokens)
  end

  test "parses an assign statement" do
    tokens = [
      Token.ident("this"),
      Token.assign(),
      Token.int("2")
    ]

    assert ["=", ["this", 2]] = Parser.parse_expression(tokens)
  end

  test "parses an assign that is the result of an add"
  #  test "parses an assign that is the result of an add" do
  #    tokens = [
  #      Token.ident("this"),
  #      Token.assign(),
  #      Token.int("1"),
  #      Token.plus(),
  #      Token.int("2")
  #    ]
  #
  #    assert ["=", ["this", 2]] = Parser.parse_expression(tokens)
  #  end
end
