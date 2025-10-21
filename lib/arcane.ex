defmodule Arcane do
  @moduledoc """
  Main module for the compiler application

  This module serves as an entry point for interacting with all points of the compiler
  """
  alias Arcane.Compiler

  @doc "Compile the expression and dump C code to stdout"
  def compile_expression(expr) do
    expr
    |> Compiler.compile_s_expression()
    |> Compiler.compile_c(:stdout)
  end

  @doc "Compile the expression and create a runnable executable"
  def compile_and_build(expr, output_name \\ "arcane") do
    # Ensure application is started
    Application.ensure_all_started(:arcane)

    expr
    |> Compiler.compile_s_expression()
    |> Compiler.compile_c(output_name)
  end
end
