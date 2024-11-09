defmodule SExpr.Compiler do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def compile(ast) do
    {result, state} = generate_code(ast, %{counter: 0, code: [], vars: %{}})
    
    """
    ; Module header
    source_filename = "#{Time.utc_now()}.ll"
    target triple = "#{get_cached_triple()}"
    attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="all" }

    define i32 @main() {
    entry:
    #{Enum.join(Enum.reverse(state.code), "\n")}
      ret i32 #{result}
    }
    """
  end

  def save_ir(ir_code, output_name) do 
    File.write!("#{output_name}.ll", ir_code)
  end

  def compile_to_executable(output_name) do
    ir_file = "#{output_name}.ll"
    
    with {:ok, _} <- llvm_compile_to_object(ir_file),
         {:ok, linker_args} <- get_cached_linker_args(output_name),
         {:ok, _} <- link_executable(output_name, linker_args) do
      {:ok, output_name}
    else
      error -> error
    end
  end

  def init(_) do
    initial_state = %{
      target_triple: detect_target_triple(),
      linker_base_args: get_base_linker_args()
    }
    {:ok, initial_state}
  end

  defp get_base_linker_args do
    triple = detect_target_triple() 
    cond do 
      is_binary(triple) and String.contains?(triple, "darwin") ->
        arch = if String.contains?(triple, "aarch64"), do: "arm64", else: "x86_64"
        ["-arch", arch, "-lSystem"]
      true ->
        []
    end
  end

  def handle_call(:get_triple, _from, state), do: {:reply, state.target_triple, state}
  def handle_call(:get_linker_args, _from, state), do: {:reply, state.linker_base_args, state}

  defp get_cached_triple, do: GenServer.call(__MODULE__, :get_triple)
  
  defp get_cached_linker_args(output_name) do
    base_args = GenServer.call(__MODULE__, :get_linker_args)
    {:ok, base_args ++ ["#{output_name}.o", "-o", output_name]}
  end

  defp detect_target_triple do
    {arch, 0} = System.cmd("uname", ["-m"])
    {platform, 0} = System.cmd("uname", ["-s"])
    
    case {String.trim(arch), String.trim(platform)} do
      {"arm64", "Darwin"} -> "aarch64-apple-darwin"
      {"x86_64", "Darwin"} -> "x86_64-apple-darwin"
      {"x86_64", "Linux"} -> "x86_64-pc-linux-gnu"
      _ -> raise "Unsupported platform: #{platform} on #{arch}"
    end
  end

  defp llvm_compile_to_object(ir_file) do
    basename = Path.basename(ir_file, ".ll")
    case System.cmd("llc", ["-filetype=obj", ir_file, "-o", "#{basename}.o"]) do
      {_, 0} -> {:ok, "#{basename}.o"}
      {error, _} -> {:error, "LLC compilation failed: #{error}"}
    end
  end

  def link_executable(basename, linker_args) do
    case System.cmd("clang", linker_args) do
      {_, 0} -> {:ok, basename}
      {error, _} -> {:error, "Linking failed: #{error}"}
    end
  end

  # Code generation functions remain the same
  defp generate_code([op | args], state) when op == :+ do
    {values, new_state} = args
    |> Enum.reduce({[], state}, fn arg, {values, curr_state} ->
      {value, next_state} = eval_expr(arg, curr_state)
      {[value | values], next_state}
    end)

    result_reg = new_state.counter 
    [left, right] = Enum.reverse(values)
    add_instr = "  %#{result_reg} = add i32 #{left}, #{right}"
    
    final_state = %{
      new_state |
      counter: result_reg + 1,
      code: [add_instr | new_state.code]
    }

    {"%#{result_reg}", final_state}
  end

  defp eval_expr(num, state) when is_integer(num) do
    {Integer.to_string(num), state}
  end
end
