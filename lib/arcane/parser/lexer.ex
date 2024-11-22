defmodule Arcane.Lexer do
  @moduledoc """
  This module is responsible for taking raw language input and converting it to a stream of 
  tokens for the parser to ingest.
  """
  alias Arcane.Token

  @equal 61
  @gt 62
  @plus 43
  @comma 44
  @space 32
  @newline 10
  @paren_l 40
  @paren_r 41
  @colon 58

  @doc "This is temporary until lexing and parsing is more feature complete"
  def pass_through(expr), do: expr

  @doc """
  Tokenize converts a string into a series of tokens
  """
  @spec tokenize(String.t()) :: [Token.t()]
  def tokenize(expr) do
    parse_expression(expr, "", [])
  end

  def next_token(expr) do
    {token, rest} = parse_token(expr, %Token{})

    {token, rest}
  end

  def peak_token(expr) do
    {token, _rest} = parse_token(expr, %Token{})

    {token, expr}
  end

  defp parse_token(<<c, n, rest::binary>> = str, %Token{term: term} = token)
       when not is_nil(term) do
    append_recurse = fn ->
      token = %{token | term: <<term::binary, (<<c>>)>>}

      parse_token(<<n, rest::binary>>, token)
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
        {token, <<n, rest::binary>>}

      # =
      <<?=>> == term ->
        token = Token.assign(token)
        {token, str}

      # Float case
      c == ?. and numeric?(term) and n in ?0..?9 ->
        token = %{token | term: <<term::binary, <<c>>, (<<n>>)>>}
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

  # eat whitespace
  defp parse_token(<<_c, rest::binary>>, %Token{term: _, type: :unknown} = token),
    do: parse_token(rest, token)

  # don't eat whitespace in strings
  defp parse_token(<<c, rest::binary>>, %Token{term: term, type: :string} = token),
    do: parse_token(rest, %{token | term: <<c, term>>})

  #    cond do
  #      c in ?0..?9 -> {Token.int(c), ""}
  #      c in ?a..?z or c in ?A..?Z or c == ?_ -> 
  #      c in [?=, ?,, ?+] -> {parse_single(c), ""}
  #      true -> {Token.ident(c), ""}
  #    end
  #  end

  # -----------------------------------------------------------------------------
  #  Given a completed term - associate it with the type of token it should be
  # -----------------------------------------------------------------------------
  defp identify_token(%Token{term: term, type: :unknown} = token) do
    cond do
      identifier?(term) -> Token.ident(token)
      numeric?(term) -> Token.int(token)
      true -> Token.illegal(term)
    end
  end

  defp identify_token(%Token{type: :string, term: term} = token) do
    %{token | term: String.replace(term, "\"", "")}
  end

  # Parse the hot path first
  @spec parse_expression(String.t(), String.t(), [Token.t()]) ::
          [{atom(), Token.value_types()}]
  defp parse_expression("", current, out) do
    {type, current} = parse_value(current)

    if type == :illegal do
      out
    else
      [{type, current} | out]
    end
    |> Enum.reverse()
  end

  defp parse_expression(<<c, rest::binary>>, current, out) do
    {{type, c} = tuple, rest} = parse_char(c, rest)

    case type do
      :ident when current == "" and c == @space ->
        parse_expression(rest, "", out)

      :ident ->
        parse_expression(rest, <<current::binary, (<<c>>)>>, out)

      :eat ->
        parse_expression(rest, current, out)

      _type ->
        out = merge_expression(tuple, current, out)
        parse_expression(rest, "", out)
    end
  end

  defp merge_expression(tuple, "", out), do: [tuple | out]

  defp merge_expression(tuple, current, out) do
    value =
      current
      |> String.trim()
      |> parse_value()

    [tuple | [value | out]]
  end

  defp parse_char(binary_val, rest) do
    {c, tl_rest} =
      (fn
         "" -> {nil, ""}
         <<c, tl_rest::binary>> -> {c, tl_rest}
       end).(rest)

    case {binary_val, c} do
      {@equal, @gt} -> {Token.expr_open(), tl_rest}
      {@equal, _} -> {Token.assign(), rest}
      {@plus, _} -> {Token.plus(), rest}
      {@comma, _} -> {Token.comma(), rest}
      {@paren_l, _} -> {Token.paren_l(), rest}
      {@paren_r, _} -> {Token.paren_r(), rest}
      {@colon, @colon} -> {Token.declare(), tl_rest}
      {@space, _} -> {Token.ident(@space), rest}
      {@newline, _} -> {{:eat, nil}, rest}
      {val, _} -> {Token.ident(<<val>>), rest}
    end
  end

  @spec parse_value(String.t()) :: {atom(), Token.value_types() | nil}
  defp parse_value(val) do
    cond do
      val == "" -> Token.illegal(val)
      val == "end" -> Token.expr_close()
      numeric?(val) -> Token.int(val)
      float?(val) -> Token.float(val)
      string?(val) -> Token.string(val)
      true -> Token.ident(val)
    end
  end

  @spec identifier?(String.t()) :: boolean()
  defp identifier?(val), do: val =~ ~r/^[a-zA-Z][a-zA-Z0-9_]*$/

  @spec numeric?(String.t()) :: boolean()
  defp numeric?(val), do: val =~ ~r/^\d+$/

  @spec float?(String.t()) :: boolean()
  defp float?(val), do: val =~ ~r/^-?\d+\.\d+$/

  @spec string?(String.t()) :: boolean()
  defp string?(val), do: val =~ ~r/^".*"$/
end
