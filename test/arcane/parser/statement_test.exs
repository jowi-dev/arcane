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

  describe "append/2" do
    test "appends an initial value to the statement" do
      statement = Statement.new()
      two = Token.int(2)

      assert %{state: :parse, expected: :operator, message: "", tokens: [^two]} =
               Statement.append(statement, two)
    end

    test "rejects initial token if it is an operator"
    test "appends either a value or an operator to the statement"
    test "marks the statement complete if it can be evaluated"
  end
end
