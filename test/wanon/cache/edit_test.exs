defmodule EditTest do
  use ExUnit.Case
  alias Wanon.Cache.CacheEntry
  import Ecto.Query, only: [from: 1]

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  @update %{
    "edited_message" => %{
      "message_id" => 2,
      "date" => 1540590127,
      "edit_date" => 1540590133,
      "text" => "My message II"
    }
  }

  test "select edit messages" do
    assert Wanon.Cache.Edit.selector(@update)
  end

  test "ignore other messages" do
    refute Wanon.Cache.Edit.selector(%{"message" => %{}})
  end

  test "edit existing message in cache" do
    Wanon.Repo.insert(%CacheEntry{chat_id: 1, message_id: 2, date: 3, message: %{"spam" => 2}})

    Wanon.Cache.Edit.execute(@update)

    updated = Wanon.Repo.one(from(c in CacheEntry))
    assert updated.message == @update["edited_message"]
  end

  test "edit missing message in cache" do
    Wanon.Cache.Edit.execute(@update)

    refute Wanon.Repo.one(from(c in CacheEntry))
  end
end
