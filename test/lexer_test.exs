defmodule Arcane.LexerTest do
  use ExUnit.Case

  alias Arcane.Lexer

  test "Tokenizes Adding" do
    # Test your parser/lexer
    tokens =
      Lexer.tokenize("""
        1 + 2
      """)

    assert tokens == [
             {:int, 1},
             {:plus, "+"},
             {:int, 2}
           ]

    assert Lexer.tokenize("1 + 2") == Lexer.tokenize("1+2")
  end

  test "Tokenizes assignments" do
    tokens =
      Lexer.tokenize("""
        thing = 1
      """)

    assert tokens == [
             {:ident, "thing"},
             {:assign, "="},
             {:int, 1}
           ]

    assert Lexer.tokenize("thing = 1") == Lexer.tokenize("thing=1")
  end

  test "Tokenizes comma" do
    tokens =
      Lexer.tokenize("""
        thing,1
      """)

    assert tokens == [
             {:ident, "thing"},
             {:comma, ","},
             {:int, 1}
           ]

    assert Lexer.tokenize("thing,1") == Lexer.tokenize("thing,1")
  end

  # When it is time to parse more involved expressions - use this
  #  defp get_fixture(filename) do
  #    # Get absolute path to test fixture
  #    filepath = Path.join([__DIR__, "fixtures", "#{filename}.arc"])
  #
  #    # Read the file content
  #    {:ok, content} = File.read(filepath)
  #
  #    content
  #    |> IO.inspect(limit: :infinity, pretty: true, label: "content")
  #  end
end
