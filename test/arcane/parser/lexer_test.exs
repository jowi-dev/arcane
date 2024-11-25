defmodule Arcane.Parser.LexerTest do
  use ExUnit.Case

  alias Arcane.Parser.Lexer
  alias Arcane.Parser.Token

  describe "next_token/1" do
    test "gets the next identifier" do
      {token, rest} = Lexer.next_token("a = b")

      assert rest == " = b"
      assert %Token{term: "a", type: :ident} = token
    end

    test "gets the next assignment" do
      {token, rest} = Lexer.next_token(" = 2")

      assert rest == " 2"
      assert %Token{term: "=", type: :assign} = token
    end

    test "gets the next int" do
      {token, rest} = Lexer.next_token("1 + 2")

      assert rest == " + 2"
      assert %Token{term: 1, type: :int} = token
    end

    test "gets the next string" do
      {token, rest} = Lexer.next_token("\"hello\"")

      assert rest == ""
      assert %Token{term: "hello", type: :string} = token
    end
  end

  describe "peak_token/1" do
    test "returns a token, but leaves the input unchanged" do
      token = Lexer.peak_token("a = b", expected: :value)

      assert %Token{term: "a", type: :ident} = token
    end
  end

  #  describe "tokenize/1" do
  #    test "Tokenizes assignments" do
  #      tokens =
  #        Lexer.tokenize("""
  #          thing = 1
  #        """)
  #
  #      assert tokens == [
  #               {:ident, "thing"},
  #               {:assign, "="},
  #               {:int, 1}
  #             ]
  #
  #      assert Lexer.tokenize("thing = 1") == Lexer.tokenize("thing=1")
  #    end
  #
  #    test "Tokenizes comma" do
  #      tokens =
  #        Lexer.tokenize("""
  #          thing,1
  #        """)
  #
  #      assert tokens == [
  #               {:ident, "thing"},
  #               {:comma, ","},
  #               {:int, 1}
  #             ]
  #
  #      assert Lexer.tokenize("thing,1") == Lexer.tokenize("thing,1")
  #    end
  #
  #    test "Tokenizes a float" do
  #      tokens =
  #        Lexer.tokenize("""
  #        37.2
  #        """)
  #
  #      assert tokens == [{:float, 37.2}]
  #    end
  #
  #    test "Tokenizes an int" do
  #      tokens =
  #        Lexer.tokenize("""
  #        37
  #        """)
  #
  #      assert tokens == [{:int, 37}]
  #    end
  #
  #    test "Tokenizes a string" do
  #      tokens =
  #        Lexer.tokenize("""
  #        "hello world"
  #        """)
  #
  #      assert tokens == [{:string, "hello world"}]
  #    end
  #
  #    test "Tokenizes expression open" do
  #      tokens =
  #        Lexer.tokenize("""
  #        =>
  #        """)
  #
  #      assert tokens == [{:expr_open, "=>"}]
  #    end
  #
  #    test "Tokenizes expression close" do
  #      tokens =
  #        Lexer.tokenize("""
  #        end
  #        """)
  #
  #      assert tokens == [{:expr_close, "end"}]
  #    end
  #
  #    test "Tokenizes paren open" do
  #      tokens =
  #        Lexer.tokenize("""
  #        (
  #        """)
  #
  #      assert tokens == [{:paren_open, "("}]
  #    end
  #
  #    test "Tokenizes paren close" do
  #      tokens =
  #        Lexer.tokenize("""
  #        ) 
  #        """)
  #
  #      assert tokens == [{:paren_close, ")"}]
  #    end
  #
  #    test "Tokenizes declaration" do
  #      tokens =
  #        Lexer.tokenize("""
  #        ::
  #        """)
  #
  #      assert tokens == [{:declare, "::"}]
  #    end
  #  end

  # When it is time to parse more involved expressions - use this
  #  defp get_fixture(filename) do
  #    # Get absolute path to test fixture
  #    filepath = Path.join([__DIR__, "fixtures", "#{filename}.arc"])
  #
  #    # Read the file content
  #    {:ok, content} = File.read(filepath)
  #
  #    content
  #  end
end
