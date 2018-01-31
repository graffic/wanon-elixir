defmodule BuilderTest do
  use ExUnit.Case
  alias Wanon.Quotes.CacheEntry

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  @potato %{"potato" => 1}
  @spam %{"spam" => 2}
  @eggs %{"eggs" => 3}
  @bacon %{"bacon" => 4}

  test "build without cache entries" do
    res = Wanon.Quotes.Builder.build_from(-1, -2, @potato)
    assert [@potato] == res
  end

  test "One entry" do
    Wanon.Repo.insert %CacheEntry{
      chat_id: 1, message_id: 2, date: 3, message: @spam}
    res = Wanon.Quotes.Builder.build_from(1, 2, @potato)
    assert [@spam] == res
  end

  test "Multiple entries" do
    Wanon.Repo.insert %CacheEntry{
      chat_id: 1, message_id: 2, date: 3, message: @spam}
    Wanon.Repo.insert %CacheEntry{
      chat_id: 1, message_id: 3, reply_id: 2, date: 3, message: @eggs}
    Wanon.Repo.insert %CacheEntry{
      chat_id: 1, message_id: 4, reply_id: 3, date: 3, message: @bacon}
    
    res = Wanon.Quotes.Builder.build_from(1, 4, @potato)
    assert [@spam, @eggs, @bacon] == res
  end
end