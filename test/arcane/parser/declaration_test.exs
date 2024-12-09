defmodule Arcane.Parser.DeclarationTest do
  use ExUnit.Case
  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Expression
  alias Arcane.Parser.Token

  describe "parse/1 - Functions" do
    test "parses a function definition" do
      assert {:ok, decl, ""} =
               Declaration.parse("""
               myFunc :: func(num, numtwo) => {
                 num + numtwo
               }
               """)

      num1 = Token.ident("num")
      num2 = Token.ident("numtwo")
      assert [%Expression{type: "func", args: [^num1, ^num2]}] = decl.expressions
      assert decl.type == "func"
    end
  end

  describe "parse/1 - Structs" do
  end

  describe "parse/1 - Tests" do
  end
end
