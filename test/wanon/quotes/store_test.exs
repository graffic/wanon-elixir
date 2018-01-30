defmodule StoreTest do
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  test "stores quote entries with the right order" do
    creator = %{
      "first_name" => "Javier"}
    
    {:ok, quote} = Wanon.Quotes.Store.store(["spam", "eggs", "bacon"], creator)
    assert "{\"first_name\":\"Javier\"}" == quote.creator
    assert [0, 1, 2] = Enum.map(quote.entries, &(&1.order))
    assert ["\"spam\"", "\"eggs\"", "\"bacon\""] = Enum.map(quote.entries, &(&1.message))
  end
end