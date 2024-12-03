defmodule Arcane.Parser.DeclarationTest do
  use ExUnit.Case
  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Expression
  alias Arcane.Parser.Token

  describe "next_declaration/1 - Functions" do
    test "parses a function definition" do
      assert {:ok, decl, ""} =
               Declaration.parse("""
               myFunc :: func(num, numtwo) =>
                 num + numtwo
               end
               """)

      num1 = Token.ident("num")
      num2 = Token.ident("numtwo")
      plus = Token.plus()
      assert [%Expression{type: "func", args: [^num1, ^num2]}] = decl.expressions
    end
  end

  describe "next_declaration/1 - Structs" do
  end

  describe "next_declaration/1 - Tests" do
  end
end
