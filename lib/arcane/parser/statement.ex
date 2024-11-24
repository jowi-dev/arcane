defmodule Arcane.Parser.Statement do
  @moduledoc """
  This module is to help the Parser digest statements

  a Statement is a collection of tokens that can be evaluated.

  For Example

  1 + 2 <- this is a statement
  this = 1 + 2 <- this is also a statement

  # This multi-line sequence is one statement
  matches =
    [1,2,3]
    |> Enum.filter(&is_even/1)
    |> List.first()
  """
  defstruct complete?: false,
            state: :init,
            current: nil,
            expected: :value

  @type t :: %{
          complete?: boolean(),
          state: :init | :parse | :complete,
          current: Arcane.Parser.Token.t() | nil,
          expected: :value | :operator
        }
end
