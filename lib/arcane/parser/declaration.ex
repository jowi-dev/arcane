defmodule Arcane.Parser.Declaration do
  @moduledoc """
  This module describes a construct which notates *what* lives inside a module

  Declarations can be:
  - MVP - Functions
  - TODO - Type or Struct Definitions
  - TODO - Test Definitions
  """

  alias Arcane.Parser.Expression
  alias Arcane.Parser.Lexer
  alias Arcane.Parser.Token

  @type t :: %{
          name: String.t(),
          type: :unknown | :function | :pfunction | :struct | :module | :value,
          expressions: list(Expression.t())
        }

  defstruct name: "",
            type: :unknown,
            expressions: []

  @doc """
  Given an unparsed expression, find the next declaration and return that along
  with the remainder of the expression
  """
  @spec parse(String.t()) :: {__MODULE__.t() | nil, String.t()}
  def parse(expr) do
    # TODO - typing will go here
    # TODO - operator overload will need multiple expressions returned
    with {%Token{type: :ident} = token, rest} <- Lexer.next_token(expr),
         {%Token{type: :declare}, rest} <- Lexer.next_token(rest),
         {:ok, %Expression{} = expr, rest} <- Expression.parse_expression(rest) do
      declaration = %__MODULE__{
        name: token.term,
        type: expr.type,
        expressions: [expr]
      }

      {:ok, declaration, rest}
    else
      {error, rest} ->
        IO.inspect(error)
        {nil, rest}
    end
  end

  defp get_declaration(<<?\s, rest::binary>>, token), do: get_declaration(rest, token)
  defp get_declaration(<<?\t, rest::binary>>, token), do: get_declaration(rest, token)
  defp get_declaration(<<?\n, rest::binary>>, token), do: get_declaration(rest, token)

  defp get_declaration(<<"func", rest::binary>>, token) do
    IO.puts("WIN")
    #    args = get_args(rest)
    #    statements = get_statements(rest)

    %__MODULE__{
      name: token.term,
      type: :function,
      expressions: []
    }
  end

  defp get_args(<<"(", rest::binary>>) do
    # Get the remainder of the phrase before the expression open
    rest
    |> declaration_line()
    |> String.replace(")", "")
    |> String.split(",")
    |> Enum.map(fn arg ->
      arg
      |> String.trim()
      |> Token.ident()
    end)
  end

  defp get_statements(rest) do
    # Get the remainder of the phrase before the expression open
    arg_str = declaration_line(rest)

    # remove the rest of the args from the expression
    rest = String.replace(rest, arg_str, "")
  end

  defp declaration_line(expr) do
    expr
    |> String.splitter(["=>"])
    |> Enum.take(1)
    |> List.first()
  end
end
