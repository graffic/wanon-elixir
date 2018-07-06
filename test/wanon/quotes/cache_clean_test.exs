defmodule CacheCleanTest do
  use ExUnit.Case
  import Ecto.Query
  alias Wanon.Quotes.CacheClean
  alias Wanon.Quotes.CacheEntry

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  test "Deletes old cache entries" do
    # Add some entries
    now = DateTime.to_unix(DateTime.utc_now())

    %CacheEntry{
      chat_id: 1,
      message_id: 2,
      reply_id: nil,
      date: now,
      message: %{text: "spam"}
    }
    |> Wanon.Repo.insert()

    %CacheEntry{
      chat_id: 1,
      message_id: 3,
      reply_id: nil,
      date: now - 3000,
      message: %{text: "eggs"}
    }
    |> Wanon.Repo.insert()

    # Do the cleaning job
    CacheClean.handle_info(:clean, %{every: 0, keep: 2000})

    # Check entries.
    assert Wanon.Repo.one(from(q in Wanon.Quotes.CacheEntry, select: count("*"))) == 1
  end

  test "Schedules next" do
    CacheClean.handle_info(:clean, %{every: 300, keep: 2000})
    refute_receive :clean, 100
    assert_receive :clean, 500
  end

  test "Initializes genserver with right parameters" do
    {:ok, res} = start_supervised(CacheClean)
    assert :sys.get_state(res) == %{every: 42, keep: 84}
  end
end
