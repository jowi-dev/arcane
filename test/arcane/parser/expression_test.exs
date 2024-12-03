defmodule Arcane.Parser.ExpressionTest do
  use ExUnit.Case

  alias Arcane.Parser.Expression
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  test "Evaluates a function" do
    one = Token.ident("one")
    two = Token.ident("two")
    plus = Token.plus()

    assert {:ok,
            %Expression{
              type: "func",
              args: [^one, ^two],
              body: [%Statement{} = stmt]
            },
            ""} =
             Expression.parse_expression("""
             func(one, two) => one + two
             """)

    assert [^plus, [^one, ^two]] = Statement.to_tokens(stmt)
  end

  test "Evaluates a multi-line function" do
    one = Token.ident("one")
    two = Token.ident("two")
    val = Token.ident("val")
    assign = Token.assign()
    three = Token.int(3)
    plus = Token.plus()

    assert {:ok,
            %Expression{
              type: "pfunc",
              args: [^one, ^two],
              body: [%Statement{} = val_3, %Statement{} = stmt | []]
            },
            ""} =
             Expression.parse_expression("""
               pfunc(one, two) => {
                 val = one + two

                 val + 3
               }
             """)

    assert [^assign, [^val, [^plus, [^one, ^two]]]] = Statement.to_tokens(stmt)
    assert [^plus, [^val, ^three]] = Statement.to_tokens(val_3)
  end

  test "Evaluates a private function" do
    one = Token.ident("one")
    two = Token.ident("two")
    plus = Token.plus()

    assert {:ok,
            %Expression{
              type: "pfunc",
              args: [^one, ^two],
              body: [%Statement{} = stmt]
            },
            ""} =
             Expression.parse_expression("""
             pfunc(one, two) => one + two
             """)

    assert [^plus, [^one, ^two]] = Statement.to_tokens(stmt)
  end
end
