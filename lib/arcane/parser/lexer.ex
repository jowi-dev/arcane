defmodule Arcane.Parser.Lexer do
  @moduledoc """
  This module is responsible for taking raw language input and converting it to a stream of 
  tokens for the parser to ingest.
  """
  alias Arcane.Parser.Token

  @doc "This is temporary until lexing and parsing is more feature complete"
  def pass_through(expr), do: expr

  @spec next_token(String.t()) :: {Token.t(), String.t()}
  def next_token(expr) do
    {token, rest} = parse_token(expr, %Token{})

    {token, rest}
  end

  @spec peak_token(String.t()) :: Token.t()
  def peak_token(expr, opts \\ []) do
    expected = Keyword.get(opts, :expected, :operator)
    eat_newline? = Keyword.get(opts, :eat_newline?, true)
    {token, rest} = parse_token(expr, %Token{})

    case {token, expected, eat_newline?} do
      {%{type: :newline}, _, true} -> peak_token(rest, opts)
      {%{family: family} = token, family, _} -> token
      {_, _, _} -> Token.endline()
    end
  end

  defp parse_token(<<c, rest::binary>> = str, %Token{term: term} = token)
       when not is_nil(term) do
    append_recurse = fn ->
      token = %{token | term: <<term::binary, (<<c>>)>>}

      parse_token(rest, token)
    end

    cond do
      # 87385934.3423425
      float?(term) and c in ?0..?9 ->
        append_recurse.()

      # 83754985
      c in ?0..?9 and numeric?(term) ->
        append_recurse.()

      # variable names
      identifier?(term) and (identifier?(<<c>>) or numeric?(<<c>>)) ->
        append_recurse.()

      # match symbol
      <<?@>> == term and c == ?? ->
        token = %{token | term: <<term::binary, (<<c>>)>>}
        token = Token.match(token)
        {token, rest}

      # =>
      <<?=>> == term and c == ?> ->
        token = %{token | term: <<term::binary, (<<c>>)>>}
        token = Token.expr_open(token)
        {token, rest}

      <<?:>> == term and c == ?: ->
        token = %{token | term: <<term::binary, (<<c>>)>>}
        token = Token.declare(token)
        {token, rest}

      <<?=>> == term and c == ?= -> 
        token = %{token | term: <<term::binary, (<<c>>)>>}
        token = Token.equality(token)
        {token, rest}
      # =
      <<?=>> == term ->
        token = Token.assign(token)
        {token, str}

      # Float case
      c == ?. and numeric?(term) ->
        {n, rest} = next_char(rest)

        token =
          case n do
            nil -> Token.illegal(n)
            n when n in ?0..?9 -> %{token | term: <<term::binary, <<c>>, (<<n>>)>>, type: :float}
          end

        parse_token(rest, token)

      # String case
      token.type == :string ->
        if c == ?" do
          token = %{token | term: <<term::binary, (<<c>>)>>}
          token = identify_token(token)
          {token, rest}
        else
          append_recurse.()
        end

      # This means we've hit a point where consistency is broken; identify what we have and exit
      true ->
        token = identify_token(token)
        {token, str}
    end
  end

  defp parse_token("", token), do: {identify_token(token), ""}

  defp parse_token(<<c, rest::binary>>, %Token{term: nil, type: :unknown} = token)
       when c not in [?\s, ?\t, ?\n, ?", ?\\],
       do: parse_token(rest, %{token | term: <<c>>})

  defp parse_token(<<?", rest::binary>>, %Token{term: nil, type: :unknown} = token),
    do: parse_token(rest, %{token | type: :string, term: "\""})

  defp parse_token(<<?\n, rest::binary>>, token), do: {Token.newline(token), rest}
  # eat whitespace
  defp parse_token(<<_c, rest::binary>>, %Token{term: _, type: :unknown} = token),
    do: parse_token(rest, token)

  #  # don't eat whitespace in strings
  #  defp parse_token(<<c, rest::binary>>, %Token{term: term, type: :string} = token),
  #    do: parse_token(rest, %{token | term: <<term::binary, (<<c>>)>>})

  defp next_char(<<c, rest::binary>>), do: {c, rest}
  defp next_char(""), do: {nil, ""}

  # -----------------------------------------------------------------------------
  #  Given a completed term - associate it with the type of token it should be
  # -----------------------------------------------------------------------------
  defp identify_token(%Token{term: term, type: :unknown} = token) do
    cond do
      is_nil(term) -> Token.file_end()
      term == "=" -> Token.assign(token)
      term == "==" -> Token.equality()
      term == "+" -> Token.plus()
      term == "(" -> Token.paren_l()
      term == ")" -> Token.paren_r()
      term == "{" -> Token.body_open()
      term == "}" -> Token.body_close()
      term == "," -> Token.comma()
      term == "@?" -> Token.match()
      term == "@" -> Token.pattern()
      identifier?(term) -> Token.ident(token)
      numeric?(term) -> Token.int(token)
      true -> Token.illegal(term)
    end
  end

  defp identify_token(%Token{type: :string, term: term} = token) do
    %{token | term: String.replace(term, "\"", "")}
  end

  @spec identifier?(String.t()) :: boolean()
  defp identifier?(val), do: val =~ ~r/^[a-zA-Z][a-zA-Z0-9_]*$/

  @spec numeric?(String.t()) :: boolean()
  defp numeric?(val), do: val =~ ~r/^\d+$/

  @spec float?(String.t()) :: boolean()
  defp float?(val), do: val =~ ~r/^-?\d+\.\d+$/
end
