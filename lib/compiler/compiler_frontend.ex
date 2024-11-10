defmodule SExpr.Compiler.CompilerFrontend do
  @moduledoc """
  Compiler Frontend

  The objective of this module is to provide a common grammar for all targets.

  Doing this while not explicitly necessary will greatly improve the ability
  to boostrap the compiler, and therefore promote dogfooding

  Compiler expects Lisp Style S-Expressions in the format

  `{+, 1, 2}` - Bracket to represent an expression, commas to separate args

  The objective is to maximize ease of parsing
  """

  @doc ~S"""
  Parser for S-Expressions

  ## Examples
      iex> SExpr.Compiler.compile_s_expression("{+, 1, 2}")
      [:+, 1, 2]
  """
  @spec parse(String.t()) :: [String.t()]
  def parse(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.replace(" ", "")
    |> String.split("")
    |> Enum.reject(&(&1 == "" or &1 == ","))
    |> parse_tokens([])
  end

  defp parse_tokens([], ast), do: List.first(ast)
  defp parse_tokens(["{" | rest], ast), do: parse_tokens(rest, [[] | ast])

  defp parse_tokens(["}" | rest], [current | stack]) do
    parse_tokens(rest, [Enum.reverse(current) | stack])
  end

  defp parse_tokens([token | rest], [current | stack]) do
    value =
      case Integer.parse(token) do
        {num, ""} -> num
        :error -> String.to_atom(token)
      end

    parse_tokens(rest, [[value | current] | stack])
  end
end
