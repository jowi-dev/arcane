defmodule Arcane.Token do
  @type t ::
          {:operator, atom()}
          | {:number, integer()}
          | {:assign, atom()}

  @type value_types :: atom() | integer() | String.t()

  def illegal(val), do: {:illegal, val}
  def file_end, do: {:file_end, nil}
  def newline, do: {:newline, nil}
  def paren_l, do: {:paren_open, "("}
  def paren_r, do: {:paren_close, ")"}
  def declare, do: {:declare, "::"}

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
end
