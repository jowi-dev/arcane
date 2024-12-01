defmodule Arcane.ParserTest do
  use ExUnit.Case
  alias Arcane.Parser.Token
  alias Arcane.Parser

  test "parses an expression" do

    assert {:ok, true} = Parser.parse("""
      func(1, 2) => 1 + 2
      """)
  end

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

    assert {:ok, [[^assign, [^this, [^plus, [^one, ^two]]]]]} =
             Arcane.Parser.parse("this = 1 + 2")
  end

  test "parses an assign that is the result of an add - no whitespace" do
    assign = Token.assign()
    plus = Token.plus()
    this = Token.ident("this")
    one = Token.int(1)
    two = Token.int(2)

    assert {:ok, [[^assign, [^this, [^plus, [^one, ^two]]]]]} =
             Arcane.Parser.parse("this=1+2")
  end

  test "multiple statements" do
    assign = Token.assign()
    plus = Token.plus()
    first = Token.ident("first")
    second = Token.ident("second")
    one = Token.int(1)
    two = Token.int(2)

    assert {:ok,
            [
              [^assign, [^first, ^one]],
              [^assign, [^second, ^two]],
              [^plus, [^first, ^second]]
            ]} =
             Arcane.Parser.parse("""
             first = 1
             second = 2
             first + second
             """)
  end

  # TODO - meaningful errors are going to be aided by line/col numbers being reported
  #  test "reports meaningful errors" do
  #    assert {:error, error} = Arcane.Parser.parse("1 + + 2")
  #    assert error =~ "Expected number or identifier but found"
  #    assert error =~ "1 + + 2"
  #    assert error =~ "    ^"
  #  end
  #
  #  test "statements don't start with operators" do
  #    assert {:error, error} = Arcane.Parser.parse("+ 2")
  #    assert error =~ "Expected number or identifier but found"
  #    assert error =~ "+ 2"
  #    assert error =~ "^"
  #  end
end
