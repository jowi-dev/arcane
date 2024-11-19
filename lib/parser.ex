defmodule Arcane.Parser do
  @moduledoc """
  This module is responsible for taking tokenized grammar and converting it to 
  an AST for the compiler frontend to consume
  """

  alias Arcane.Token

  @operators [:plus, :assign]
  @values [:ident, :float, :int, :string]

  @doc "delete this when parsing works"
  def pass_through(tokens), do: tokens

  @doc """
  Converts a tokenized list of the expression into an s_expression style list

  Doing this lets us compile parsed tokens into the various backends
      ### Examples
      iex> Arcane.Parser.parse_expression([Arcane.Token.int("1")])
      [1]
  """
  @spec parse_expression([Token.t()]) :: [Token.value_types()]
  def parse_expression(tokens), do: generate_ast(tokens, [])

  defp generate_ast(tokens, out) when tokens != [] do
    [head | tail] = tokens

    {current, rest} = append_statement(head, [], tail)

    if tail == [],
      do: [current | out],
      else: generate_ast(rest, [current | out])
  end

  defp generate_ast([], out), do: List.first(out)

  defp append_statement({type, _val} = curr, stmt, next) do
    previous_type =
      if stmt == [] do
        :start
      else
        {type, _} = hd(stmt)
        type
      end

    {head, tail} =
      if next == [] do
        {nil, []}
      else
        [head | tail] = next
        {head, tail}
      end

    cond do
      type in @values and previous_type in @operators ->
        append_statement(head, [curr | stmt], tail)

      type in @operators and previous_type in @values ->
        append_statement(head, [curr | stmt], tail)

      type in @values and previous_type in @values ->
        # This is a statement end indicator
        statement =
          [curr | stmt]
          |> Enum.reverse()
          |> parse_statement()

        {statement, next}

      previous_type == :start ->
        append_statement(head, [curr], tail)

      type in @operators and previous_type in @operators ->
        raise "parser error"
    end
  end

  defp append_statement(nil, current, []), do: {parse_statement(Enum.reverse(current)), []}
  defp append_statement(nil, [], []), do: []
  defp append_statement(curr, [], next), do: append_statement(hd(next), [curr], tl(next))

  defp parse_statement([{_, val}]), do: val

  defp parse_statement(statement) do
    [{_, val} | [{_, operator} | rest]] = statement

    next =
      rest
      |> parse_statement()

    [operator, [val, next]]
  end
end
