defmodule Arcane.Token do
  @type t ::
          {:operator, atom()}
          | {:number, integer()}
          | {:assign, atom()}

  @type value_types :: atom() | integer() | String.t()
end
