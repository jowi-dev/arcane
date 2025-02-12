defmodule Arcane.Parser.Statement do
  @moduledoc """
  This module is to help the Parser digest statements

  a Statement is a collection of tokens that can be evaluated.

  For Example

  1 + 2 <- this is a statement
  this = 1 + 2 <- this is also a statement

  # This multi-line sequence is one statement
  matches =
    [1,2,3]
    |> Enum.filter(&is_even/1)
    |> List.first()
  """

  alias Arcane.Parser.Lexer

  defstruct state: :init,
            tokens: [],
            expected: :value,
    message: "",
    opts: %{express?: true}

  @type t :: %{
          state: :init | :parse | :complete | :error,
          tokens: [Arcane.Parser.Token.t()] | [],
          expected: :value | :operator,
          message: String.t()
        }

  def new(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  @spec parse_statement(String.t(), __MODULE__.t()) :: {:ok | :error, __MODULE__.t(), String.t()}
  def parse_statement(expr, stmt \\ %__MODULE__{}) do
    {%{family: family} = token, rest} =
      Lexer.next_token(expr)
    |> IO.inspect(limit: :infinity, pretty: true, label: "from statement")

    cond do
      family in [:value, :operator] ->
        case append(stmt, token) do
          %{state: :complete} = statement ->
            # peak next token to ensure there isnt a continuation
            %{family: new_family, type: type} = Lexer.peak_token(rest, expected: statement.expected)

            if new_family == family or token.type == :endline or (type == :expr_open and not stmt.opts.express?),
              do: {:ok, statement, rest},
              else: parse_statement(rest, statement)

          %{state: :error} = statement ->
            {:error, statement, rest}

          statement ->
            parse_statement(rest, statement)
        end

      token.type == :file_end ->
        {:ok, stmt, ""}

      true ->
        {:ok, stmt, rest}
    end
  end

  @doc """
  Given a special form it may make sense to collect tokens before collecting them as a statement
  from_tokens/2 gives us a way to turn tokens into a statement
  """
  @spec from_tokens([Token.t()], __MODULE__.t()) :: {:ok | :error, __MODULE__.t(), String.t()}
  def from_tokens(tokens, statement \\ %__MODULE__{}) do

  end

  def to_tokens(%{tokens: tokens}) when length(tokens) >= 3 do
    tokens
    |> Enum.reverse()
    |> s_express()
  end

  def to_tokens(%{tokens: tokens}), do: Enum.reverse(tokens)

  defp s_express([token]), do: token

  defp s_express(tokens) do
    [val, operator | rest] = tokens

    [operator, [val, s_express(rest)]]
  end

  defp invert(:value), do: :operator
  defp invert(:operator), do: :value

  @spec append(__MODULE__.t(), Arcane.Token.t()) :: __MODULE__.t()
  def append(%{expected: family, state: state} = statement, %{family: family} = token)
      when state != :init do
    statement =
      Map.merge(statement, %{
        tokens: [token | statement.tokens],
        expected: invert(statement.expected)
      })

    if complete?(statement) do
      Map.put(statement, :state, :complete)
    else
      statement
    end
  end

  def append(%{state: :init} = statement, %{family: :value} = token) do
    Map.merge(statement, %{
      tokens: [token],
      expected: invert(statement.expected),
      state: :parse
    })
  end

  def append(%{tokens: [%{family: fam} | _]} = statement, %{family: fam} = token) do
    Map.merge(statement, %{
      message: "Expected #{statement.expected}, Found: #{token.type} in family: #{token.family}",
      state: :error
    })
  end

  def append(%{state: :init} = statement, %{family: :operator} = token) do
    Map.merge(statement, %{
      message:
        "Statements must begin with a value e.g. `myVar` or `2` or \"hello\". Found: #{token.term} of type: #{token.type}",
      state: :error
    })
  end

  # Naive: A statement is complete if it has an odd number of tokens
  # 1 + 2
  # this = 1 + 2
  defp complete?(statement) do
    length = length(statement.tokens)

    length >= 3 and rem(length, 2) == 1
  end
end
