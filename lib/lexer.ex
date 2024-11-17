defmodule Arcane.Lexer do
  @moduledoc """
  This module is responsible for taking raw language input and converting it to a stream of 
  tokens for the parser to ingest.
  """
  alias Arcane.Token

  @spec tokenize(String.t()) :: [Token.t()]
  def tokenize(expr) do
    expr
    |> parse_expression("", [])
    |> Enum.reject(&(elem(&1, 0) == :error))
  end

  @type s_expr_types :: atom() | integer() | String.t()
  # Parse the hot path first
  @spec parse_expression(String.t(), String.t(), [Token.t()]) ::
          {String.t(), [s_expr_types()]}
  defp parse_expression("", current, out) do
    {type, current} = parse_value(current)

    if type == :error do
      out
    else
      [{type, current} | out]
    end
    |> Enum.reverse()
  end

  defp parse_expression(<<c, rest::binary>>, current, out) do
    {type, c} = parse_char(c)

    case type do
      :assign ->
        parse_expression(rest, "", [:assign | out])

      :ident ->
        parse_expression(rest, <<current::binary, (<<c>>)>>, out)

      :operator when current != "" ->
        # Current then operator
        current = parse_value(current)
        out = [{type, c} | [current | out]]
        parse_expression(rest, "", out)

      :operator ->
        # Current then operator
        current = parse_value(current)
        out = [{type, c} | [current | out]]
        parse_expression(rest, "", out)

      :eat when current != "" ->
        {type, current} = parse_value(current)
        parse_expression(rest, "", [{type, current} | out])

      :eat when current == "" ->
        parse_expression(rest, current, out)
    end
  end

  defp parse_char(61), do: {:assign, "="}

  # 10 = " " 32 = "\n"
  defp parse_char(val) when val in [10, 32], do: {:eat, nil}
  defp parse_char(val) when val in [43], do: {:operator, String.to_atom(<<val>>)}
  defp parse_char(val), do: {:ident, val}

  @spec parse_value(String.t()) :: {atom(), s_expr_types() | nil}
  defp parse_value(val) do
    cond do
      val == "" -> {:error, nil}
      numeric?(val) -> {:number, String.to_integer(val)}
      float?(val) -> {:float, String.to_float(val)}
      string?(val) -> {:string, String.replace(val, "\"", "")}
      true -> {:ident, String.to_atom(val)}
    end
  end

  @spec numeric?(String.t()) :: boolean()
  defp numeric?(val), do: val =~ ~r/^\d+$/

  @spec float?(String.t()) :: boolean()
  defp float?(val), do: val =~ ~r/^-?\d+\.\d+$/

  @spec string?(String.t()) :: boolean()
  defp string?(val), do: val =~ ~r/^".*"$/
end
