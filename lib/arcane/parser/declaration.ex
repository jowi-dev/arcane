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
      {_error, rest} ->
        {nil, rest}
    end
  end
end
