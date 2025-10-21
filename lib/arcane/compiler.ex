defmodule Arcane.Compiler do
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
  alias Arcane.Compiler.CompilerFrontend
  alias Arcane.Compiler.CBackend

  @outdir "./target/"

  @doc ~S"""
  Parser for S-Expressions

  ## Examples
      iex> Arcane.Compiler.compile_s_expression("{+ 1 2}")
      [:+, 1, 2]
  """
  @spec compile_s_expression(String.t()) :: [String.t()]
  defdelegate compile_s_expression(str), to: CompilerFrontend, as: :parse

  @doc """
  Function call for the C Backend

  ast: The resulting string list returned from parsing an input
  output_name: The outfile that the resulting file will be named - inside the target/ dir

  Option to push compilation output to stdout via output_name = :stdout
  """
  @spec compile_c([String.t()], String.t() | :stdout) ::
          {:ok, String.t()} | :ok | {:error, String.t()}
  def compile_c(ast, :stdout) do
    c_code = CBackend.compile(ast)
    IO.puts(c_code)
    :ok
  end

  def compile_c(ast, output_name) do
    c_code = CBackend.compile(ast)

    CBackend.save_c(c_code, output_name, @outdir)
    CBackend.generate_executable(output_name, @outdir)
  end
end
