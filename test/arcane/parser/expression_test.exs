defmodule Arcane.Parser.ExpressionTest do
  use ExUnit.Case

  alias Arcane.Parser.Expression
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  test "Evaluates a function" do
    one = Token.ident("one")
    two = Token.ident("two")
    plus = Token.plus()
    
    assert {:ok, %Expression{
      type: "func",
      args: [^one, ^two],
      body: [%Statement{} = stmt]
    }, ""} = Expression.parse_expression("""
      func(one, two) => one + two
      """)

    assert [^plus, [^one, ^two]] = Statement.to_tokens(stmt)
  end
end
