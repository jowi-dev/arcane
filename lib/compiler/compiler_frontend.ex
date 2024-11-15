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
    |> parse_expression("", %{}, 0, 0)
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
  # 1 => [:+, 100, :hold0]
  # 2 => [:-, 200, :hold1]
  # 3 => [:*, :hold2, 15]
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
  defp parse_expression(<<c, rest::binary>>, current, out, idx, max_idx) when c == 123 do
    new_idx = max_idx + 1

    nested_hold = "hold"
    current = <<current::binary, nested_hold::binary>>
    |> IO.inspect(limit: :infinity, pretty: true, label: "")

    out = Map.put(out, idx, current)

    parse_expression(rest, "", out, new_idx, new_idx)
  end

  # 125 = "}"
  defp parse_expression(<<c, rest::binary>>, current, out, idx, max_idx) when c == 125 do

    if byte_size(rest) == 0 do
      IO.inspect(current, limit: :infinity, pretty: true, label: "final")
      Map.put(out, idx, current)
    else

    curr_expr = Map.get(out, idx, "")

    # TODO - this is due to a deeper bug; fix it
    out = 
      if curr_expr == current do 
        out 
      else 
        expr = <<curr_expr::binary, current::binary>>
        |> IO.inspect(limit: :infinity, pretty: true, label: "")

        Map.put(out, idx, expr)
      end


    prev = Map.get(out, idx - 1, "")
      parse_expression(rest, prev, out, idx - 1, max_idx)
    end
  end

  defp parse_expression(<<c, rest::binary>>, current, out, idx, max_idx) do
    current = <<current::binary, (<<c>>)>>
    |> IO.inspect(limit: :infinity, pretty: true, label: "")
    parse_expression(rest, current, out, idx, max_idx)
  end

  defp compile_expression(expr_map) do
    expr_map
    |> Map.to_list()
    |> split_and_parse(1, [])
    |> concat_map()
  end

  defp split_and_parse([], idx, out), do: {Enum.into(out, %{}), idx}

  defp split_and_parse([{k, v} | rest], idx, out) do
    {idx, v} =
      v
      |> String.split()
      |> Enum.reduce({idx, []}, fn value, {idx, acc} ->
        case parse_value(value) do
          :hold -> {idx + 1, [{:hold, idx} | acc]}
          val -> {idx, [val | acc]}
        end
      end)

    new_kv = {k, Enum.reverse(v)}
    split_and_parse(rest, idx, [new_kv | out])
  end

  defp concat_map({map, max_idx}), do: concat_map(map, max_idx - 1)

  defp concat_map(map, 0), do: Map.get(map, 1)

  defp concat_map(map, idx) do
    values =
      map
      |> IO.inspect(limit: :infinity, pretty: true, label: "")
      |> Map.get(idx)
      |> Enum.map(fn
        {:hold, num} ->
          Map.get(map, num)

        val ->
          val
      end)

    map
    |> Map.put(idx, values)
    |> concat_map(idx - 1)
  end

  def parse_value(val) do
    cond do
      numeric?(val) -> String.to_integer(val)
      "hold" == val -> :hold
      true -> String.to_atom(val)
    end
  end

  def numeric?(val), do: val =~ ~r/^\d+$/
end
