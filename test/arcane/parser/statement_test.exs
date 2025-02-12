defmodule Arcane.Parser.StatementTest do
  use ExUnit.Case

  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  describe "new/0" do
    test "returns a fresh statement struct for use" do
      assert %Statement{
               state: :init,
               tokens: [],
               expected: :value,
               message: ""
             } == Statement.new()
    end
  end

  describe "parse_statement" do
    test "parses an add statement" do
      plus = Token.plus()
      one = Token.int(1)
      two = Token.int(2)

      assert {:ok, %Statement{} = stmt, ""} = Statement.parse_statement("1 + 2")
      assert [^plus, [^one, ^two]] = Statement.to_tokens(stmt)
    end

    test "parses an add statement - no whitespace" do
      plus = Token.plus()
      one = Token.int(1)
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("1+2")
      assert [^plus, [^one, ^two]] = Statement.to_tokens(stmt)
    end

    test "parses an assign statement" do
      assign = Token.assign()
      this = Token.ident("this")
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("this = 2")
      assert [^assign, [^this, ^two]] = Statement.to_tokens(stmt)
    end

    test "parses an assign statement - no whitespace" do
      assign = Token.assign()
      this = Token.ident("this")
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("this=2")
      assert [^assign, [^this, ^two]] = Statement.to_tokens(stmt)
    end

    test "parses an assign that is the result of an add" do
      assign = Token.assign()
      plus = Token.plus()
      this = Token.ident("this")
      one = Token.int(1)
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("this = 1 + 2")
      assert [^assign, [^this, [^plus, [^one, ^two]]]] = Statement.to_tokens(stmt)
    end

    test "parses an assign that is the result of an add - no whitespace" do
      assign = Token.assign()
      plus = Token.plus()
      this = Token.ident("this")
      one = Token.int(1)
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("this=1+2")
      assert [^assign, [^this, [^plus, [^one, ^two]]]] = Statement.to_tokens(stmt)
    end

    test "parses equality statement" do
      eq = Token.equality()
      one = Token.int(1)
      two = Token.int(2)

      assert {:ok, stmt, ""} = Statement.parse_statement("1 == 2")
      assert [^eq, [^one, ^two]] = Statement.to_tokens(stmt)
    end
  end

  describe "append/2" do
    test "appends an initial value to the statement" do
      statement = Statement.new()
      two = Token.int(2)

      assert %{state: :parse, expected: :operator, message: "", tokens: [^two]} =
               Statement.append(statement, two)
    end

    test "rejects initial token if it is an operator" do
      statement = Statement.new()
      assign = Token.assign()

      assert %{state: :error, expected: :value, message: message, tokens: []} =
               Statement.append(statement, assign)

      assert message ==
               "Statements must begin with a value e.g. `myVar` or `2` or \"hello\". Found: #{assign.term} of type: #{assign.type}"
    end

    test "rejects the token if its family is not expected" do
      statement = Statement.new()
      two = Token.int(2)
      statement = Statement.append(statement, two)
      three = Token.int(3)

      assert %{state: :error, expected: :operator, message: message, tokens: [^two]} =
               Statement.append(statement, three)

      assert message ==
               "Expected #{statement.expected}, Found: #{three.type} in family: #{three.family}"
    end

    test "appends either a value or an operator to the statement" do
      statement = Statement.new()
      two = Token.int(2)
      statement = Statement.append(statement, two)

      assign = Token.assign()

      assert %{state: :parse, expected: :value, message: "", tokens: [^assign, ^two]} =
               Statement.append(statement, assign)
    end

    test "marks the statement complete if it can be evaluated" do
      statement = Statement.new()
      two = Token.int(2)
      statement = Statement.append(statement, two)
      plus = Token.plus()
      statement = Statement.append(statement, plus)

      three = Token.int(3)

      assert %{state: :complete, expected: :operator, message: "", tokens: [^three, ^plus, ^two]} =
               Statement.append(statement, three)
    end
  end
end
