defmodule Arcane.Parser.Statement do
  @moduledoc """
  This module is to help the Parser digest statements

  a Statement is a collection of tokens that can be evaluated.

  For Example

  1 + 2 <- this is a statement
  this = 1 + 2 <- this is also a statement

  # This multi-line sequence is one statement
  matches =
    [1,2,3]
    |> Enum.filter(&is_even/1)
    |> List.first()
  """
  defstruct state: :init,
            tokens: [],
            expected: :value,
            message: ""

  @type t :: %{
          state: :init | :parse | :complete | :error,
          tokens: [Arcane.Parser.Token.t()] | [],
          expected: :value | :operator,
          message: String.t()
        }

  @spec append(__MODULE__.t(), Arcane.Token.t()) :: __MODULE__.t()
  def append(%{tokens: [%{family: curr_fam} | _]} = statement, %{family: new_fam} = token)
      when curr_fam != new_fam do
    statement = Map.put(statement, :tokens, [token | statement.tokens])

    if complete?(statement) do
      Map.put(statement, :state, :complete)
    else
      statement
    end
  end

  def append(%{state: :init} = statement, %{family: :value} = token) do
    Map.merge(statement, %{
      tokens: [token],
      state: :parse
    })
  end

  def append(%{tokens: [%{family: fam} | _]} = statement, %{family: fam} = token) do
    Map.merge(statement, %{
      message: "Expected #{statement.expected}, Found: #{token.type} in family: #{token.family}",
      state: :error
    })
  end

  def append(%{state: :init} = statement, %{family: :operator} = token) do
    Map.merge(statement, %{
      message:
        "Statements must begin with a value e.g. `myVar` or `2` or \"hello\". Found: #{token.term} of type: #{token.type}",
      state: :error
    })
  end

  # Naive: A statement is complete if it has an odd number of tokens
  # 1 + 2
  # this = 1 + 2
  defp complete?(statement) do
    length = length(statement.tokens)

    length >= 3 and rem(length, 2) == 1
  end
end
