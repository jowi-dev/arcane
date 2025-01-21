defmodule Arcane.Parser.BranchTest do
  use ExUnit.Case

  alias Arcane.Parser.Branch
  alias Arcane.Parser.Token

  test "parses a branch of a match" do
    val = Token.ident("value")
    two = Token.int(2)
    eq = Token.equality()
    str = Token.string("the value is two")

    assert %Branch{
      if: [^eq, [^val, ^two]],
      success: [^str]
        } = Branch.parse("""
          value == 2 => "the value is two"
        """)
  end
  
end
