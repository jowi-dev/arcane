defmodule Arcane.ParserTest do
  use ExUnit.Case
  alias Arcane.Parser.Token
  alias Arcane.Parser

  test "parses an expression" do
    assert {:ok, _decl, ""} =
             Parser.parse("""
             myFunc :: func(num, numtwo) => num + numtwo
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
