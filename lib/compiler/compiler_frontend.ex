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

  def parse_value(val) do
    cond do 
      numeric?(val) -> String.to_integer(val)
      true -> String.to_atom(val)
    end
  end

  def numeric?(val), do: val =~ ~r/^\d+$/
  # -----------------------------------------------------------------------------
    # { +
      # 100,
      # { 
        # - 
        # 200,
        # { 
          # *
          # { 
            # / 
            # 100 ,
            # 2 }, 15 } } }
  # %{
    # 1 => ":+ 100 <2>"
    # 2 => ":- 200 <3>"
    # 3 => ":* <4> 15"
    # 4 => ":/ 100 2"
  # }
  # 
  # Compilation Stage would go...
  # idx => 4 -> done, full expression
  # idx => 3 -> append 4 -> 3, collect 15 as second arg, close ]
  # idx => 2 -> append 3 -> 2, close ]
  # idx => 1 -> append 2 -> 1, close ]
  # idx => 0 -> Complete expression
  # -----------------------------------------------------------------------------

  # 123 = "{"
  defp parse_expression(<<c, rest::binary>>, current, out, idx) when c == 123 do 
    # 91 = "["
    new_idx = idx + 1

    nested_hold = "hold"
    current = <<current::binary, nested_hold::binary>>

    out = Map.put(out, idx, current)

    parse_expression(rest, "", out, new_idx)
  end

  defp parse_expression(<<c, rest::binary>>, current, out, idx) when c == 125 do 
    curr_expr = Map.get(out, idx, "")

    expr = <<curr_expr::binary, current::binary>>

    #{expr, out} = maybe_inject_nested(expr, out, idx + 1)

    out = Map.put(out, idx, expr)

    parse_expression(rest, "", out, idx - 1)
  end

  defp parse_expression(<<c, rest::binary>>, current, out, idx) do
    current = <<current::binary, <<c>> >>
    parse_expression(rest, current, out, idx)
  end

  defp parse_expression(_, _, out, 0), do: out

  defp compile_expression(expr_map) do
    expr =
      expr_map
      |> Map.to_list
      |> Enum.map(fn {k, v} -> 
        v = v |> String.split() |> Enum.map(&parse_value/1)
        has_hold? = Enum.any?(v, & &1 == :hold)
        v = Enum.with_index(v, fn val, idx -> {idx, val} end) |> Enum.into(%{})
        {k, v, has_hold?}
      end)

    concat_map(expr) |> List.first()
  end

  defp concat_map([{_k, v, false}]), do: Map.values(v)

  defp concat_map([{_k, v, true} | rest]) do 
    {hold_key, _} = Enum.find(v, fn {_k, map_val} -> map_val == :hold end)

    Map.put(v, hold_key, concat_map(rest)) |> Map.values()
  end
end
