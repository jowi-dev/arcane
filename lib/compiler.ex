defmodule SExpr.Compiler do
  alias SExpr.Compiler.LLVMBackend

  @outdir "./target/"

  @spec compile_llvm([String.t()], String.t() | :stdout) :: 
    {:ok, String.t()} | :ok | {:error, String.t()}
  def compile_llvm(ast, :stdout), do: LLVMBackend.compile(ast)
  def compile_llvm(ast, output_name) do
    ir_code = LLVMBackend.compile(ast)

    LLVMBackend.save_ir(ir_code, output_name, @outdir)
    LLVMBackend.generate_executable(output_name, @outdir)
  end
end
