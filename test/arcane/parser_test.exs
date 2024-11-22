defmodule Arcane.ParserTest do
  use ExUnit.Case
  # doctest Arcane.Parsec
  alias Arcane.Parser.Token

  test "parses an add statement" do
    assert {:ok, [:plus, [{:int, 1}, {:int, 2}]]} =
             Arcane.Parser.parse("1 + 2")
  end

  test "parses an add statement - no whitespace" do
    assert {:ok, [:plus, [{:int, 1}, {:int, 2}]]} =
             Arcane.Parser.parse("1+2")
  end

  test "parses an assign statement" do
    assert {:ok, [[%Token{type: :assign}, [%Token{type: :ident, term: "this"}, %Token{type: :int, term: 2}]]]} =
             Arcane.Parser.parse("this = 2")
  end

  test "parses an assign statement - no whitespace" do
    assert {:ok, [:assign, [{:identifier, "this"}, {:int, 2}]]} =
             Arcane.Parser.parse("this=2")
  end

  test "parses an assign that is the result of an add" do
    assert {:ok, [:assign, [{:identifier, "this"}, [:plus, [{:int, 1}, {:int, 2}]]]]} =
             Arcane.Parser.parse("this = 1 + 2")
  end

  test "parses an assign that is the result of an add - no whitespace" do
    assert {:ok, [:assign, [{:identifier, "this"}, [:plus, [{:int, 1}, {:int, 2}]]]]} =
             Arcane.Parser.parse("this=1+2")
  end

  test "multiple statements" do
    assert {:ok,
            [
              [:assign, [{:identifier, "first"}, {:int, 1}]],
              [:assign, [{:identifier, "second"}, {:int, 2}]],
              [:plus, [{:identifier, "first"}, {:identifier, "second"}]]
            ]} =
             Arcane.Parser.parse("""
             first = 1
             second = 2
             first + second
             """)
  end

  test "reports meaningful errors" do
    assert {:error, error} = Arcane.Parser.parse("1 + + 2")
    assert error =~ "Expected number or identifier but found"
    assert error =~ "1 + + 2"
    assert error =~ "    ^"
  end

  test "statements don't start with operators" do
    assert {:error, error} = Arcane.Parser.parse("+ 2")
    assert error =~ "Expected number or identifier but found"
    assert error =~ "+ 2"
    assert error =~ "^"
  end
end
