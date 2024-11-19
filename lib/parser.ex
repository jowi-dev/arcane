defmodule Arcane.Parser do
  @moduledoc """
  This module is responsible for taking tokenized grammar and converting it to 
  an AST for the compiler frontend to consume
  """

  alias Arcane.Token

  @operators [:plus]

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

  defp generate_ast(tokens, out) when length(tokens) > 2 do
    [head | tail] = tokens

    {next, tokens} =
      case head do
        {type, _val} when type in [:ident, :int, :float] ->
          parse_statement(head, tail)
      end

    generate_ast(tokens, [next | out])
  end

  # This will need some validation to ensure we want this value in out
  defp generate_ast([{_type, val}], out), do: [val | out]

  defp generate_ast([], out), do: List.first(out)

  defp parse_statement({_type, val}, expr) do
    [peak | tail] = expr

    case peak do
      {peak_type, peak_val} when peak_type in @operators ->
        # TODO - input validation on type or parse error
        [{_tl_type, tl_val} | rest] = tail
        {[peak_val, [val, tl_val]], rest}
    end
  end
end
