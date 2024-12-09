defmodule Arcane.Parser.DeclarationTest do
  use ExUnit.Case
  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Expression
  alias Arcane.Parser.Token

  describe "parse/1 - Modules" do
    test "parses a module declaration" do
      {:ok, decl, _} =
        Declaration.parse("""
        MyModule :: module => {
          myFunc :: func(num, numtwo) => {
            num + numtwo
          }
        }
        """)

      num1 = Token.ident("num")
      num2 = Token.ident("numtwo")
      assert decl.type == "module"
      assert [%Expression{type: "module", args: [], body: [func_decl]}] = decl.expressions
      assert [%Expression{type: "func", args: [^num1, ^num2]}] = func_decl.expressions
    end
  end

  describe "parse/1 - Functions" do
    test "parses a function declaration" do
      assert {:ok, decl, _} =
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
