defmodule Arcane.Lexer do
  @moduledoc """
  This module is responsible for taking raw language input and converting it to a stream of 
  tokens for the parser to ingest.
  """
  alias Arcane.Token

  @doc "This is temporary until lexing and parsing is more feature complete"
  def pass_through(expr), do: expr

  @doc """
  Tokenize converts a string into a series of tokens
  """
  @spec tokenize(String.t()) :: [Token.t()]
  def tokenize(expr) do
    expr
    |> parse_expression("", [])
  end

  # Parse the hot path first
  @spec parse_expression(String.t(), String.t(), [Token.t()]) ::
          [{atom(), Token.value_types()}]
  defp parse_expression("", current, out) do
    {type, current} = parse_value(current)

    if type == :illegal do
      out
    else
      [{type, current} | out]
    end
    |> Enum.reverse()
  end

  defp parse_expression(<<c, rest::binary>>, current, out) do
    {type, c} = tuple = parse_char(c)

    case type do
      :ident ->
        parse_expression(rest, <<current::binary, (<<c>>)>>, out)

      _type ->
        out = merge_expression(tuple, current, out)
        parse_expression(rest, "", out)
    end
  end

  defp merge_expression({:eat, _}, "", out), do:  out
  defp merge_expression({:eat, _}, current, out), do:  [parse_value(current) | out]
  defp merge_expression(tuple, "", out), do: [tuple | out]
  defp merge_expression(tuple, current, out) do 
    value = parse_value(current)
    [tuple | [value | out]]
  end

  defp parse_char(61), do: Token.assign()

  # 10 = " " 32 = "\n"
  defp parse_char(val) when val in [10, 32], do: {:eat, nil}
  defp parse_char(43), do: Token.plus()
  defp parse_char(val), do: Token.ident(val)

  @spec parse_value(String.t()) :: {atom(), Token.value_types() | nil}
  defp parse_value(val) do
    cond do
      val == "" -> Token.illegal(val)
      numeric?(val) -> Token.int(val)
      float?(val) -> Token.float(val)
      string?(val) -> Token.string(val)
      true -> Token.ident(val)
    end
  end

  @spec numeric?(String.t()) :: boolean()
  defp numeric?(val), do: val =~ ~r/^\d+$/

  @spec float?(String.t()) :: boolean()
  defp float?(val), do: val =~ ~r/^-?\d+\.\d+$/

  @spec string?(String.t()) :: boolean()
  defp string?(val), do: val =~ ~r/^".*"$/
end
