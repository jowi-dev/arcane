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

  test "Tokenizes a float" do
    tokens =
      Lexer.tokenize("""
      37.2
      """)

    assert tokens == [{:float, 37.2}]
  end

  test "Tokenizes an int" do
    tokens =
      Lexer.tokenize("""
      37
      """)

    assert tokens == [{:int, 37}]
  end

  test "Tokenizes a string" do
    tokens =
      Lexer.tokenize("""
      "hello world"
      """)

    assert tokens == [{:string, "hello world"}]
  end

  test "Tokenizes expression open" do
    tokens =
      Lexer.tokenize("""
      =>
      """)

    assert tokens == [{:expr_open, "=>"}]
  end

  test "Tokenizes expression close" do
    tokens =
      Lexer.tokenize("""
      end
      """)

    assert tokens == [{:expr_close, "end"}]
  end

  test "Tokenizes paren open" do
    tokens =
      Lexer.tokenize("""
      (
      """)

    assert tokens == [{:paren_open, "("}]
  end

  test "Tokenizes paren close" do
    tokens =
      Lexer.tokenize("""
      ) 
      """)

    assert tokens == [{:paren_close, ")"}]
  end

  test "Tokenizes declaration" do
    tokens =
      Lexer.tokenize("""
      ::
      """)

    assert tokens == [{:declare, "::"}]
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
