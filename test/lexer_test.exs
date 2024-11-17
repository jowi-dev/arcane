defmodule Arcane.LexerTest do
  use ExUnit.Case

  alias Arcane.Lexer

  #  test "if given a string, pass through" do
  #    str = "hello world"
  #
  #    assert "hello world" = Lexer.tokenize(str)
  #  end

  test "Tokenizes Adding" do
    # Get absolute path to test fixture
    filepath = Path.join([__DIR__, "fixtures", "add.arc"])

    # Read the file content
    {:ok, content} = File.read(filepath)

    # Test your parser/lexer
    tokens = Lexer.tokenize(content)

    assert tokens == [
             {:number, 1},
             {:operator, :+},
             {:number, 2}
           ]
  end
end
