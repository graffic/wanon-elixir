defmodule Wanon.Quotes.CacheEntry do
  use Ecto.Schema

  schema "messages_cache" do
    field :chat_id, :integer
    field :message_id, :integer
    field :reply_id, :integer, default: nil
    field :date, :integer
    field :message, :binary
  end
end