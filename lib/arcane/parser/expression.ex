defmodule Arcane.Parser.Expression do
  @moduledoc """
    Expressions are a statement or collection of statements which make up functionality
  """

  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  @typedoc """
  Expression types are representative of the forms available in the core grammar
  :func - Function
  :pfunc - private function
  :struct - a struct
  :module - module
  :anon - anonymous function
  """
  @type expression_types :: :func | :pfunc | :struct | :module | :anon

  defstruct [
    args: [],
    type: :anon,
    body: []
  ]

  @type t :: %{
    args: list(Token.t()),
    body: list(Statement.t()),
    type: expression_types()
  }



end

