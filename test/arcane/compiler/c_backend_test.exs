defmodule Arcane.Compiler.CBackendTest do
  use ExUnit.Case
  doctest Arcane.Compiler.CBackend

  alias Arcane.Compiler.CBackend

  describe "compile/1" do
    test "compiles simple integer" do
      result = CBackend.compile(42)
      
      assert result =~ "#include <stdio.h>"
      assert result =~ "int main() {"
      assert result =~ "printf(\"%d\\n\", 42);"
      assert result =~ "return 0;"
    end

    test "compiles simple addition" do
      result = CBackend.compile([:+, 1, 2])
      
      assert result =~ "#include <stdio.h>"
      assert result =~ "int main() {"
      assert result =~ "int tmp0 = 1 + 2;"
      assert result =~ "printf(\"%d\\n\", tmp0);"
      assert result =~ "return 0;"
    end

    test "compiles addition with larger numbers" do
      result = CBackend.compile([:+, 100, 2543])
      
      assert result =~ "int tmp0 = 100 + 2543;"
      assert result =~ "printf(\"%d\\n\", tmp0);"
    end

    test "compiles nested addition" do
      result = CBackend.compile([:+, [:+, 3, 5], 2])
      
      # Should generate two temporary variables
      assert result =~ "int tmp0 = 3 + 5;"
      assert result =~ "int tmp1 = tmp0 + 2;"
      assert result =~ "printf(\"%d\\n\", tmp1);"
    end
  end

  describe "save_c/3" do
    test "saves C code to file" do
      temp_dir = System.tmp_dir!()
      output_name = "test_output"
      c_code = "#include <stdio.h>\nint main() { return 0; }"

      CBackend.save_c(c_code, output_name, temp_dir <> "/")
      
      file_path = "#{temp_dir}/#{output_name}.c"
      assert File.exists?(file_path)
      assert File.read!(file_path) == c_code

      # Clean up
      File.rm!(file_path)
    end

    test "creates output directory if it doesn't exist" do
      temp_dir = System.tmp_dir!() <> "/test_arcane_dir/"
      output_name = "test_output"
      c_code = "#include <stdio.h>\nint main() { return 0; }"

      CBackend.save_c(c_code, output_name, temp_dir)
      
      assert File.exists?(temp_dir)
      assert File.exists?("#{temp_dir}#{output_name}.c")

      # Clean up
      File.rm_rf!(temp_dir)
    end
  end

  describe "generate_executable/2" do
    test "compiles C code to executable using system compiler" do
      temp_dir = System.tmp_dir!() <> "/test_arcane_compile/"
      output_name = "test_executable"
      
      # Create a simple C program
      c_code = """
      #include <stdio.h>
      int main() {
          printf("Hello from Arcane!\\n");
          return 0;
      }
      """

      File.mkdir_p!(temp_dir)
      File.write!("#{temp_dir}#{output_name}.c", c_code)

      result = CBackend.generate_executable(output_name, temp_dir)
      
      assert {:ok, ^output_name} = result
      assert File.exists?("#{temp_dir}#{output_name}")

      # Clean up
      File.rm_rf!(temp_dir)
    end

    test "returns error when C compilation fails" do
      temp_dir = System.tmp_dir!() <> "/test_arcane_fail/"
      output_name = "test_fail"
      
      # Create invalid C code
      invalid_c_code = "this is not valid C code at all"

      File.mkdir_p!(temp_dir)
      File.write!("#{temp_dir}#{output_name}.c", invalid_c_code)

      result = CBackend.generate_executable(output_name, temp_dir)
      
      assert {:error, error_msg} = result
      assert error_msg =~ "C compilation failed"

      # Clean up
      File.rm_rf!(temp_dir)
    end
  end

  describe "generated C code structure" do
    test "includes proper headers and main function" do
      result = CBackend.compile([:+, 10, 20])
      
      lines = String.split(result, "\n")
      
      # Check structure
      assert Enum.at(lines, 0) == "#include <stdio.h>"
      assert Enum.at(lines, 1) == ""
      assert Enum.at(lines, 2) == "int main() {"
      assert Enum.at(lines, -2) == "}"
    end

    test "properly formats variable assignments" do
      result = CBackend.compile([:+, 42, 58])
      
      assert result =~ ~r/int tmp\d+ = 42 \+ 58;/
    end

    test "handles multiple operations with proper variable numbering" do
      result = CBackend.compile([:+, [:+, 1, 2], [:+, 3, 4]])
      
      # Should have tmp0, tmp1, tmp2
      assert result =~ "tmp0"
      assert result =~ "tmp1" 
      assert result =~ "tmp2"
    end
  end
end