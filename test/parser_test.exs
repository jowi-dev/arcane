defmodule Arcane.ParserTest do
  use ExUnit.Case

  alias Arcane.Parser

  test "if given a string, pass through" do
    str = "hello world"

    assert "hello world" = Parser.generate_ast(str)
  end
end
