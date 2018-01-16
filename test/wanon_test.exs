defmodule WanonTest do
  use ExUnit.Case
  doctest Wanon

  test "greets the world" do
    assert Wanon.hello() == :world
  end
end
