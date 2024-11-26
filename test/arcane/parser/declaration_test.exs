defmodule Arcane.Parser.DeclarationTest do
  use ExUnit.Case
  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  describe "next_declaration/1 - Functions" do
    test "parses a function definition" do
      assert {:ok, decl} = Declaration.next_declaration("""
        myFunc :: func(num1, num2) =>
          num1 + num2
        end
        """)

    num1 = Token.ident("num1")
    num2 = Token.ident("num2")
    plus = Token.plus()
    assert [^num1, ^num2] = decl.args
    assert :function == decl.type
    assert [%Statement{tokens: [^plus, [^num1, ^num2]]}] = decl.statements
    end

  end

  describe "next_declaration/1 - Structs" do
  end
  describe "next_declaration/1 - Tests" do
  end
  
end
