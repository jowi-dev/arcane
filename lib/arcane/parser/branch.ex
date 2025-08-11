defmodule Arcane.Parser.Branch do
  @moduledoc """
  Branch is a language to describe match expressions in a more granular detail

  Each arm of a match expression has a boolean evaluation on the LHS which maps to a success state on the right if it is true.
  """
  alias Arcane.Parser.Lexer
  alias Arcane.Parser.Statement
  alias Arcane.Parser.Token

  defstruct if: [],
            success: [],
            parse_stage: :if

  @type t :: %__MODULE__{
          if: [Token.t()],
          success: [Token.t()],
          parse_stage: :if | :success | :ok
        }

  @doc """
    Parses the next available branch from the given string.
  """
  @spec parse(String.t(), __MODULE__.t()) ::
          {:ok, __MODULE__.t(), String.t()} | {:error, String.t()}
  def parse(input, branch \\ %__MODULE__{}) do
    {token, rest} = Lexer.next_token(input)

    case {token, branch} do
      {%Token{type: :file_end}, branch} ->
        {:ok, branch, input}

      {%Token{type: :expr_open}, %__MODULE__{parse_stage: :if}} ->
        branch = Map.put(branch, :parse_stage, :success)
        parse(rest, branch)

      {_token, %{parse_stage: :if}} ->
        {:ok, statement, rest} =
          Statement.parse_statement(input, Statement.new(%{opts: %{express?: false}}))

        branch = Map.put(branch, :if, Statement.to_tokens(statement))
        parse(rest, branch)

      {%{type: :newline}, branch} ->
        branch

      {_token, %{parse_stage: :success}} ->
        {:ok, statement, rest} = Statement.parse_statement(input)
        branch = Map.put(branch, :success, Statement.to_tokens(statement))
        parse(rest, branch)
    end
  end

  def new(condition, success) do
    %__MODULE__{
      if: condition,
      success: success
    }
  end
end
