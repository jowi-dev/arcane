defmodule Arcane.Parser.Declaration do
  @moduledoc """
  This module describes a construct which notates *what* lives inside a module

  Declarations can be:
  - MVP - Functions
  - TODO - Type or Struct Definitions
  - TODO - Test Definitions
  """

  @type t :: %{
    type: :unknown | :function | :pfunction | :struct,
    args: list(Arcane.Parser.Token.t()),
    statements: list(Arcane.Parser.Statement.t())

  }

  defstruct [
    type: :unknown
  ]


end

