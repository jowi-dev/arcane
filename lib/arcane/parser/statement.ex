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

  def new() do
    %__MODULE__{}
  end

  def to_tokens(%{tokens: tokens}) when length(tokens) >= 3 do
    [val1, op, val2 | rest] = tokens

    s_express(rest, [op, [val2, val1]])
  end

  defp s_express([], out), do: out 

  def to_tokens(%{tokens: tokens}), do: Enum.reverse(tokens)

  defp invert(:value), do: :operator
  defp invert(:operator), do: :value

  @spec append(__MODULE__.t(), Arcane.Token.t()) :: __MODULE__.t()
  def append(%{expected: family, state: state} = statement, %{family: family} = token)
      when state != :init do
    statement =
      Map.merge(statement, %{
        tokens: [token | statement.tokens],
        expected: invert(statement.expected)
      })

    if complete?(statement) do
      Map.put(statement, :state, :complete)
    else
      statement
    end
  end

  def append(%{state: :init} = statement, %{family: :value} = token) do
    Map.merge(statement, %{
      tokens: [token],
      expected: invert(statement.expected),
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
