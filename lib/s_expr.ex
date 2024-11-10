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
    |> SExpr.Compiler.compile_llvm(:stdout)
  end

  def compile_and_build(expr, output_name \\ "program") do
    # Ensure application is started
    Application.ensure_all_started(:s_expr)
    
    expr
    |> SExpr.Parser.parse()
    |> SExpr.Compiler.compile_llvm(output_name)
  end
end
