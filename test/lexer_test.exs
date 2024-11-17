defmodule Arcane.LexerTest do
  use ExUnit.Case

  alias Arcane.Lexer

  test "if given a string, pass through" do
    str = "hello world"

    assert "hello world" = Lexer.tokenize(str)
  end
end
