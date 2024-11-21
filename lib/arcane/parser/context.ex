defmodule Arcane.Parser.Context do
  defstruct filename: nil,
            line: nil,
            col: nil,
            status: :ok,
            current: nil,
            message: ""
end
