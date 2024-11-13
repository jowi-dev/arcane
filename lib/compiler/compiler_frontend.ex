defmodule SExpr.Compiler.CompilerFrontend do
  @moduledoc """
  Compiler Frontend

  The objective of this module is to provide a common grammar for all targets.

  Doing this while not explicitly necessary will greatly improve the ability
  to boostrap the compiler, and therefore promote dogfooding

  Compiler expects Lisp Style S-Expressions in the format

  `{+ 1 2}` - Bracket to represent an expression, spaces to separate args

  The objective is to maximize ease of parsing
  """

  @doc ~S"""
  Parser for S-Expressions

  ## Examples
      iex> SExpr.Compiler.compile_s_expression("{+ 1 2}")
      [:+, 1, 2]
  """
  @spec parse(String.t()) :: [String.t()]
  def parse(str) when is_binary(str) do
    # Bracket replacing w/ {, and ,} is a hack for easier string splitting
    str
    |> parse_expression("", %{}, 0)
    |> compile_expression()
  end

  # -----------------------------------------------------------------------------
  # { +
  #   100
  #   { - 
  #     200
  #     { *
  #       { / 
  #         100
  #         2 }, 
  #       15 } } }
  #
  # Becomes ..
  #
  # %{
  # 1 => [:+, 100, :hold]
  # 2 => [:-, 200, :hold]
  # 3 => [:*, :hold, 15]
  # 4 => [:/, 100, 2]
  # }
  # 
  # Compilation Stage would go...
  # idx => 4 -> done, full expression
  # idx => 3 -> append 4 -> 3, 
  # idx => 2 -> append 3 -> 2
  # idx => 1 -> append 2 -> 1
  # idx => 0 -> Complete expression
  # -----------------------------------------------------------------------------

  # 123 = "{"
  defp parse_expression(<<c, rest::binary>>, current, out, idx) when c == 123 do
    new_idx = idx + 1

    nested_hold = "hold"
    current = <<current::binary, nested_hold::binary>>

    out = Map.put(out, idx, current)

    parse_expression(rest, "", out, new_idx)
  end

  defp parse_expression(<<c, rest::binary>>, current, out, idx) when c == 125 do
    curr_expr = Map.get(out, idx, "")

    expr = <<curr_expr::binary, current::binary>>

    out = Map.put(out, idx, expr)

    parse_expression(rest, "", out, idx - 1)
  end

  defp parse_expression(<<c, rest::binary>>, current, out, idx) do
    current = <<current::binary, (<<c>>)>>
    parse_expression(rest, current, out, idx)
  end

  defp parse_expression(_, _, out, 0), do: out

  defp compile_expression(expr_map) do
    expr_map
    |> Map.to_list()
    |> Enum.map(&split_and_parse/1)
    |> concat_map()
    |> List.first()
  end

  defp split_and_parse({k, v}) do
    v =
      v
      |> String.split()
      |> Enum.map(&parse_value/1)
      |> Enum.with_index(fn val, idx -> {idx, val} end)

    idx =
      case Enum.find(v, fn {_idx, val} -> val == :hold end) do
        nil -> nil
        {idx, _} -> idx
      end

    v = Enum.into(v, %{})
    {k, v, idx}
  end

  defp concat_map([{_k, v, nil}]), do: Map.values(v)

  defp concat_map([{_k, v, idx} | rest]) do
    Map.put(v, idx, concat_map(rest)) |> Map.values()
  end

  def parse_value(val) do
    cond do
      numeric?(val) -> String.to_integer(val)
      true -> String.to_atom(val)
    end
  end

  def numeric?(val), do: val =~ ~r/^\d+$/
end
