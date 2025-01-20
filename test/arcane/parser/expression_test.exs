defmodule Arcane.Parser.ExpressionTest do
  use ExUnit.Case

  alias Arcane.Parser.Branch
  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Expression
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  test "parses a match expression" do
    {:ok, expr, _} =
      Expression.parse_expression("""
      input = 2

      result = input@?(
        2 => "It is two"
        3 => "It is three"
        _val => "neither"
      )
      """)
  end

  test "parses a match" do
    {:ok, expr, _} =
      Expression.parse_expression("""
      input@(%{name: name})
      """)
  end

  test "parses a conditional match" do
    {:ok, expr, _} =
      Expression.parse_expression("""
      @?(
        1 == 2 => "It is two"
        3 == 3 => "It is three"
        true => "neither"
      )
      """)

    assert expr.type == "cond"

    assert [branch | _] = expr.body

    one = Token.int(1)
    two = Token.int(2)
    eq = Token.equality()
    str = Token.string("It is two")

    %Branch{
      if: [^one, ^eq, ^two],
      success: str
    } = branch
  end

  test "parses a module expression" do
    {:ok, expr, _} =
      Expression.parse_expression("""
      module => {
        myFunc :: func(num, numtwo) => {
          num + numtwo
        }
      }
      """)

    num1 = Token.ident("num")
    num2 = Token.ident("numtwo")
    assert expr.type == "module"
    assert [%Declaration{type: "func", expressions: [func_expr]}] = expr.body
    assert [^num1, ^num2] = func_expr.args
  end

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
            _} =
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
