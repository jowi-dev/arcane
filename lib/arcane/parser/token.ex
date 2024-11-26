defmodule Arcane.Parser.Token do
  defstruct line: 0,
            col: 0,
            term: nil,
            type: :unknown,
            family: :meta

  @type t :: %__MODULE__{
          line: integer(),
          col: integer(),
          term: value_types(),
          type: token_types()
        }

  @type token_types ::
          :number
          | :assign
          | :comma
          | :assign
          | :plus
          | :float
          | :int
          | :ident
          | :expr_open
          | :expr_close
          | :string
          | :paren_open
          | :paren_close
          | :declare
          | :illegal
          | :eat

  @type value_types ::
          atom() | integer() | String.t() | float() | list(atom() | integer() | String.t())

  # Untested - unsure if I need these yet
  def illegal(val), do: %__MODULE__{type: :illegal, term: val}
  def file_end, do: %__MODULE__{type: :file_end, term: nil}

  def newline(token \\ %__MODULE__{}),
    do: %__MODULE__{type: :newline, term: nil, col: token.col, line: token.line, family: :meta}

  def endline(),
    do: %__MODULE__{type: :endline, term: nil, family: :meta}

  # Lexer - Tested
  def comma, do: %__MODULE__{type: :comma, term: ",", family: :operator}

  def assign(token \\ %__MODULE__{}),
    do: %__MODULE__{type: :assign, term: "=", line: token.line, col: token.col, family: :operator}

  def plus(token \\ %__MODULE__{}),
    do: %__MODULE__{type: :plus, term: "+", family: :operator, line: token.line, col: token.col}

  def float(val), do: %__MODULE__{type: :float, term: String.to_float(val), family: :value}

  def int(num) when is_number(num), do: int(%__MODULE__{term: "#{num}"})

  def int(token),
    do: %__MODULE__{
      type: :int,
      term: String.to_integer(token.term),
      line: token.line,
      col: token.col,
      family: :value
    }

  def ident(ident) when is_binary(ident),
    do: %__MODULE__{type: :ident, term: ident, line: 0, col: 0, family: :value}

  def ident(token),
    do: %__MODULE__{
      type: :ident,
      term: token.term,
      line: token.line,
      col: token.col,
      family: :value
    }

  def expr_open(token), do: %__MODULE__{type: :expr_open, term: "=>", family: :operator, line: token.line, col: token.col}
  def expr_close, do: %__MODULE__{type: :expr_close, term: "end", family: :operator}

  def string(val),
    do: %__MODULE__{type: :string, term: String.replace(val, "\"", ""), family: :value}

  def paren_l, do: %__MODULE__{type: :paren_open, term: "(", family: :operator}
  def paren_r, do: %__MODULE__{type: :paren_close, term: ")", family: :operator}
  def declare(token), do: %__MODULE__{type: :declare, term: "::", family: :operator, line: token.line, col: token.col}
end
