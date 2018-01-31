defmodule Wanon.Quotes.CacheEntry do
  use Ecto.Schema

  schema "cache_entry" do
    field :chat_id, :integer
    field :message_id, :integer
    field :reply_id, :integer, default: nil
    field :date, :integer
    field :message, :map
  end
end