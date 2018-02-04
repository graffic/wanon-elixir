defmodule Wanon.Quotes.Quote do
  use Ecto.Schema

  schema "quote" do
    field :creator, :map
    field :chat_id, :integer
    has_many :entries, Wanon.Quotes.QuoteEntry
    timestamps(updated_at: false)
  end
end
