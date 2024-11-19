defmodule Arcane.Token do
  @type t ::
          {:number, integer()}
          | {:assign, atom()}
          | {:comma, String.t()}
          | {:assign, String.t()}
          | {:plus, String.t()}
          | {:float, float()}
          | {:int, integer()}
          | {:ident, String.t()}
          | {:expr_open, String.t()}
          | {:expr_close, String.t()}
          | {:string, String.t()}
          | {:paren_open, String.t()}
          | {:paren_close, String.t()}
          | {:declare, String.t()}
          | {:illegal, String.t()}
          | {:eat, nil}

  @type value_types :: atom() | integer() | String.t() | float()

  # Untested - unsure if I need these yet
  def illegal(val), do: {:illegal, val}
  def file_end, do: {:file_end, nil}
  def newline, do: {:newline, nil}

  # Lexer - Tested
  def comma, do: {:comma, ","}
  def assign, do: {:assign, "="}
  def plus, do: {:plus, "+"}
  def float(val), do: {:float, String.to_float(val)}
  def int(val), do: {:int, String.to_integer(val)}
  def ident(val), do: {:ident, val}
  def expr_open, do: {:expr_open, "=>"}
  def expr_close, do: {:expr_close, "end"}
  def string(val), do: {:string, String.replace(val, "\"", "")}
  def paren_l, do: {:paren_open, "("}
  def paren_r, do: {:paren_close, ")"}
  def declare, do: {:declare, "::"}
end
