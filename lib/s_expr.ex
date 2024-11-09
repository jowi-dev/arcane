defmodule SExpr do
  use Application
  
  def start(_type, _args) do
    children = [
      SExpr.Compiler
    ]

    opts = [strategy: :one_for_one, name: SExpr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def compile_expression(expr) do
    expr
    |> SExpr.Parser.parse()
    |> SExpr.Compiler.compile()
  end

  def compile_and_build(expr, output_name \\ "program") do
    # Ensure application is started
    Application.ensure_all_started(:s_expr)
    
    expr
    |> SExpr.Parser.parse()
    |> SExpr.Compiler.compile()
    |> SExpr.Compiler.save_ir(output_name)
    
    case SExpr.Compiler.compile_to_executable(output_name) do
      {:ok, executable} ->
        {:ok, executable}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
