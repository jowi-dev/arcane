defmodule SExpr.Parser do
  # Parser for S-expressions
  @spec parse(String.t()) :: [String.t()]
  def parse(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.replace("(", " ( ")
    |> String.replace(")", " ) ")
    |> String.split()
    |> parse_tokens([])
  end

  defp parse_tokens([], ast), do: List.first(ast)
  defp parse_tokens(["(" | rest], ast), do: parse_tokens(rest, [[] | ast])
  defp parse_tokens([")" | rest], [current | stack]) do
    parse_tokens(rest, [Enum.reverse(current) | stack])
  end
  defp parse_tokens([token | rest], [current | stack]) do
    value = case Integer.parse(token) do
      {num, ""} -> num
      :error -> String.to_atom(token)
    end
    parse_tokens(rest, [[value | current] | stack])
  end
end
