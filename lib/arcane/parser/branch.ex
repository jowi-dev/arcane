defmodule Arcane.Parser.Branch do
  @moduledoc """
  Branch is a language to describe match expressions in a more granular detail

  Each arm of a match expression has a boolean evaluation on the LHS which maps to a success state on the right if it is true.
  """
  alias Arcane.Parser.Token

  defstruct if: nil,
            success: nil

  @type t :: %__MODULE__{
          if: [Token.t()],
          success: [Token.t()]
        }

  @doc """
    Parses the next available branch from the given string.
  """
  @spec parse(String.t()) :: {:ok, __MODULE__.t(), String.t()} | {:error, String.t()}
  def parse(input) do
  end
  def new(condition, success) do
    %__MODULE__{
      if: condition,
      success: success
    }
  end
end
