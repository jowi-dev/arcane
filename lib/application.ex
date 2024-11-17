defmodule Arcane.Application do
  use Application

  def start(_type, _args) do
    children = [
      Arcane.Compiler.LLVMBackend
    ]

    opts = [strategy: :one_for_one, name: Arcane.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
