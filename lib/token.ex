defmodule Arcane.Token do
  @type t ::
          {:operator, atom()}
          | {:number, integer()}
          | {:assign, atom()}

  @type value_types :: atom() | integer() | String.t()

  def expr_open, do: {:expr_open, "=>"}
  def expr_close, do: {:expr_close, "end"}
  def illegal(val), do: {:illegal, val}
  def file_end, do: {:file_end, nil}
  def newline, do: {:newline, nil}
  def ident(val), do: {:ident, val}
  def int(val), do: {:int, String.to_integer(val)}
  def string(val), do: {:string, String.replace(val, "\"", "")}
  def float(val), do: {:float, String.to_float(val)}
  def assign, do: {:assign, "="}
  def plus, do: {:plus, "+"}
  def paren_l, do: {:paren_open, "("}
  def paren_r, do: {:paren_close, ")"}
  def comma, do: {:comma, ","}
end
