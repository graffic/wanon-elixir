defmodule StoreTest do
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  @spam %{"spam" => 2}
  @eggs %{"eggs" => 3}
  @bacon %{"bacon" => 4}
  @creator %{"first_name" => "Javier"}

  test "stores quote entries with the right order" do    
    {:ok, quote} = Wanon.Quotes.Store.store([@spam, @eggs, @bacon], @creator)
    assert @creator == quote.creator
    assert [0, 1, 2] = Enum.map(quote.entries, &(&1.order))
    assert [@spam, @eggs, @bacon] = Enum.map(quote.entries, &(&1.message))
  end
end