defmodule Wanon.Repo.Migrations.CreateMessagesCache do
  use Ecto.Migration

  def change do
    # This cache stores messages from a chat, so when a quote is asked, we can
    # store a thread of replies that happened in the last X minutes by following
    # message ids
    create table("messages_cache") do
      add :chat_id, :integer, null: false
      add :message_id, :integer, null: false
      add :reply_id, :integer, default: nil
      add :date, :integer, null: false
      add :message, :binary, null: false
    end

    create index("messages_cache", [:chat_id, :message_id], unique: true)
    create index("messages_cache", [:date])
  end
end
