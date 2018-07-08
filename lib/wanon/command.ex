defmodule Wanon.Command do
  @callback selector(event :: map) :: boolean
  @callback execute(event :: map) :: any
end
