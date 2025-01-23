defmodule Arcane.Parser.Expression do
  @moduledoc """
    Expressions are a statement or collection of statements which make up functionality
  """

  alias Arcane.Parser.Declaration
  alias Arcane.Parser.Lexer
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  @typedoc """
  Expression types are representative of the forms available in the core grammar
  :func - Function
  :pfunc - private function
  :struct - a struct
  :module - module
  :anon - anonymous function
  """
  @type expression_types :: :func | :pfunc | :struct | :module | :anon

  defstruct args: [],
            type: :anon,
            body: []

  @type t :: %{
          args: list(Token.t()),
          body: list(Statement.t()),
          type: expression_types()
        }

  def parse_expression(input, expr \\ %__MODULE__{}) do
    {rest, expression} =
      {input, expr}
      |> identify()
      |> parse_args()
      |> parse_body()

    # TODO - don't return ok if not ok
    {:ok, expression, rest}
  end

  defp identify({input, ctx}) do
    {token, rest} = Lexer.next_token(input)

    case token do
      %Token{type: :paren_open} ->
        # Leave the paren open in place for consistent arg parsing
        {input, Map.put(ctx, :type, :pfunc)}

      %Token{type: :match} ->
        IO.inspect("HIT", limit: :infinity, pretty: true, label: "")
        {input, Map.put(ctx, :type, :match)}

      # TODO - this needs safety - currently accepts any identifier as valid
      %Token{type: :ident, term: term} ->
        {rest, Map.put(ctx, :type, term)}
    end
  end

  defp parse_args({input, %{type: :match} = ctx}), do: {input, ctx}

  defp parse_args({input, ctx}) do
    {token, rest} = Lexer.next_token(input)

    case token do
      %Token{type: :paren_close} ->
        {rest, Map.put(ctx, :args, Enum.reverse(ctx.args))}

      %Token{type: type} when type in [:paren_open, :comma] ->
        parse_args({rest, ctx})

      %Token{type: :ident} = token ->
        ctx = Map.put(ctx, :args, [token | ctx.args])
        parse_args({rest, ctx})

      %Token{type: :expr_open} ->
        {input, ctx}
    end
  end

  defp parse_body({input, %{type: "module"} = ctx}) do
    {token, rest} = Lexer.next_token(input)

    case token do
      %Token{type: type} when type in [:expr_open, :body_open, :newline] ->
        parse_body({rest, ctx})

      %Token{type: type} when type in [:expr_close, :body_close, :file_end] ->
        {rest, ctx}

      %Token{type: :ident} ->
        {:ok, decl, rest} = Declaration.parse(input)
        ctx = Map.put(ctx, :body, [decl | ctx.body])

        parse_body({rest, ctx})
    end
  end

  # Matches will take the form
  # @?(
  #   1 == 2 => "1 equals 2"
  #   2 == 2 => "2 equals 2"
  # )
  # therefore they need to be parsed
  defp parse_body({input, %{type: "match"} = ctx}) do
    {token, rest} = Lexer.next_token(input)

    case token do
      %Token{type: :paren_close} ->
        {rest, ctx}

      _ ->
        {:ok, branch, rest} = Branch.parse(input)
        ctx = Map.put(ctx, :body, [branch | ctx.branches])

        parse_body({rest, ctx})
    end
  end

  defp parse_body({input, ctx}) do
    {token, rest} = Lexer.next_token(input)

    case token do
      %Token{type: type} when type in [:expr_open, :body_open] ->
        parse_body({rest, ctx})

      %Token{type: type} when type in [:expr_close, :body_close, :file_end] ->
        {rest, ctx}

      _token ->
        {:ok, stmt, rest} = Statement.parse_statement(input)

        if stmt.tokens == [] do
          parse_body({rest, ctx})
        else
          ctx = Map.put(ctx, :body, [stmt | ctx.body])

          parse_body({rest, ctx})
        end
    end
  end
end
