defmodule SExpr.Compiler do
  @moduledoc """
  The Compiler main module

  This module contains Compiler Frontend and backend calls defined as 

  Frontend - The grammar -> S-Expression generator
  Backend - S-Expression to any executable environment. 

  Current Environments Considered
  - LLVM - system level
  - Nix - build environment level 
  - Lua - Vim Level
  - JS - Web UI Level

  I write Elixir for all my server side needs, and JS would be the first out 
  as I likely have that use case covered by existing knowledge.
  """
  alias SExpr.Compiler.CompilerFrontend
  alias SExpr.Compiler.LLVMBackend

  @outdir "./target/"

  @doc """
  Parser for S-Expressions

  ## Examples
    iex> SExpr.Compiler.compile_s_expression("{+, 1, 2}")
    [:+, 1, 2]
  """
  @spec compile_s_expression(String.t()) :: [String.t()]
  defdelegate compile_s_expression(str), to: CompilerFrontend, as: :parse

  @doc """
  Function call for the LLVM Backend

  ast: The resulting string list returned from parsing an input
  output_name: The outfile that the resulting file will be named - inside the target/ dir

  Option to push compilation output to stdout via output_name = :stdout
  """
  @spec compile_llvm([String.t()], String.t() | :stdout) :: 
    {:ok, String.t()} | :ok | {:error, String.t()}
  def compile_llvm(ast, :stdout), do: LLVMBackend.compile(ast)
  def compile_llvm(ast, output_name) do
    ir_code = LLVMBackend.compile(ast)

    LLVMBackend.save_ir(ir_code, output_name, @outdir)
    LLVMBackend.generate_executable(output_name, @outdir)
  end
end
