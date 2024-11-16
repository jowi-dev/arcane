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
    str
    |> parse_expression("", [])
    |> elem(1)
    |> List.first()
  end

  defp parse_expression("", "", out), do: {"", Enum.reverse(out)}
  # 123 == "{"
  defp parse_expression(<<c, rest::binary>>, "", out) when c == 123 do
    {rest, nested_func} = parse_expression(rest, "", [])

    parse_expression(rest, "", [nested_func | out])
  end

  # 32 == " " | 125 == "}"
  defp parse_expression(<<c, rest::binary>>, current, out)
       when c == 32 or (c == 125 and byte_size(current) > 0) do
    current = parse_value(current)
    out = [current | out]

    cond do
      rest == "" ->
        {"", Enum.reverse(out)}

      c == 125 ->
        <<_space, new_rest::binary>> = rest
        {new_rest, Enum.reverse(out)}

      true ->
        parse_expression(rest, "", out)
    end
  end

  defp parse_expression(<<c, rest::binary>>, current, out) do
    current = <<current::binary, (<<c>>)>>

    parse_expression(rest, current, out)
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
