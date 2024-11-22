defmodule Arcane.Parser.Lexer do
  @moduledoc """
  This module is responsible for taking raw language input and converting it to a stream of 
  tokens for the parser to ingest.
  """
  alias Arcane.Parser.Token

  @doc "This is temporary until lexing and parsing is more feature complete"
  def pass_through(expr), do: expr

  def next_token(expr) do
    {token, rest} = parse_token(expr, %Token{})

    {token, rest}
  end

  def peak_token(expr) do
    {token, _rest} = parse_token(expr, %Token{})

    {token, expr}
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
      identifier?(term) and identifier?(<<c>>) ->
        append_recurse.()

      # =>
      <<?=>> == term and c == ?> ->

        token = %{token | term: <<term::binary, (<<c>>)>>}
        token = identify_token(token)
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
      token.type == :string and c != ?" ->
        append_recurse.()

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

  #  # eat whitespace
  #  defp parse_token(<<_c, rest::binary>>, %Token{term: _, type: :unknown} = token),
  #  do: parse_token(rest, token) |> IO.inspect(label: :whitespace)

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
