defmodule Arcane.Compiler.CBackend do
  @moduledoc """
  C backend for the Arcane compiler.
  
  Generates C code from S-expressions and compiles to native executables
  using the system's C compiler (GCC/Clang).
  """

  @doc """
  Compile AST to C code string.
  
  Takes the parsed S-expression and generates equivalent C code.
  """
  def compile(ast) do
    {result_expr, state} = generate_code(ast, %{counter: 0, code: []})
    
    """
    #include <stdio.h>
    
    int main() {
    #{Enum.join(Enum.reverse(state.code), "\n")}
        printf("%d\\n", #{result_expr});
        return 0;
    }
    """
  end

  @doc """
  Save C code to file in the specified output directory.
  """
  def save_c(c_code, output_name, outdir) do
    File.mkdir_p!(outdir)
    File.write!("#{outdir}#{output_name}.c", c_code)
  end

  @doc """
  Compile C code to executable using system C compiler.
  """
  def generate_executable(output_name, outdir) do
    c_file = "#{outdir}#{output_name}.c"
    exe_file = "#{outdir}#{output_name}"

    case System.cmd("cc", ["-o", exe_file, c_file], stderr_to_stdout: true) do
      {_, 0} -> {:ok, output_name}
      {error, _} -> {:error, "C compilation failed: #{error}"}
    end
  end

  # Code generation for different AST nodes
  
  # Handle simple integers directly
  defp generate_code(num, state) when is_integer(num) do
    {Integer.to_string(num), state}
  end

  # Handle addition operations
  defp generate_code([op | args], state) when op == :+ do
    {values, new_state} = 
      args
      |> Enum.reduce({[], state}, fn arg, {values, curr_state} ->
        {value, next_state} = eval_expr(arg, curr_state)
        {[value | values], next_state}
      end)

    result_var = "tmp#{new_state.counter}"
    [left, right] = Enum.reverse(values)
    assignment = "    int #{result_var} = #{left} + #{right};"

    final_state = %{
      new_state
      | counter: new_state.counter + 1,
        code: [assignment | new_state.code]
    }

    {result_var, final_state}
  end

  # Handle integer literals
  defp eval_expr(num, state) when is_integer(num) do
    {Integer.to_string(num), state}
  end

  # Handle other expressions recursively
  defp eval_expr(expr, state) when is_list(expr) do
    generate_code(expr, state)
  end
end