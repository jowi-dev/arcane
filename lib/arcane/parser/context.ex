defmodule Arcane.Parser.Context do
  defstruct filename: nil,
            line: nil,
            col: nil,
            status: :ok,
            current: [],
            message: ""

  @type t :: %{
          filename: String.t(),
          line: non_neg_integer(),
          col: non_neg_integer(),
          state: :ok | :error,
          current: [Arcane.Parser.Statement.t()],
          message: String.t()
        }
end
