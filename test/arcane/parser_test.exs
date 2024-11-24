defmodule Arcane.ParserTest do
  use ExUnit.Case
  alias Arcane.Parser.Token

  test "parses an add statement" do
    plus = Token.plus()
    one = Token.int(1)
    two = Token.int(2)

    assert {:ok, [[^plus, [^one, ^two]]]} =
             Arcane.Parser.parse("1 + 2")
  end

  test "parses an add statement - no whitespace" do
    plus = Token.plus()
    one = Token.int(1)
    two = Token.int(2)

    assert {:ok, [[^plus, [^one, ^two]]]} =
             Arcane.Parser.parse("1+2")
  end

  test "parses an assign statement" do
    assign = Token.assign()
    this = Token.ident("this")
    two = Token.int(2)

    assert {:ok, [[^assign, [^this, ^two]]]} =
             Arcane.Parser.parse("this = 2")
  end

  test "parses an assign statement - no whitespace" do
    assign = Token.assign()
    this = Token.ident("this")
    two = Token.int(2)

    assert {:ok, [[^assign, [^this, ^two]]]} =
             Arcane.Parser.parse("this=2")
  end

  test "parses an assign that is the result of an add" do
    assign = Token.assign()
    plus = Token.plus()
    this = Token.ident("this")
    one = Token.int(1)
    two = Token.int(2)

    assert {:ok, [^assign, [^this, [^plus, [^one, ^two]]]]} =
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
