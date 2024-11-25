defmodule Arcane.Parser.Context do
  defstruct filename: nil,
            line: nil,
            col: nil,
            status: :ok,
            statements: [],
            message: ""

  @type t :: %{
          filename: String.t(),
          line: non_neg_integer(),
          col: non_neg_integer(),
          state: :ok | :error,
          statements: [Arcane.Parser.Statement.t()],
          message: String.t()
        }
  def to_tokens(ctx) do
    Enum.map(ctx.statements, &Enum.reverse(&1.tokens))
  end
end
