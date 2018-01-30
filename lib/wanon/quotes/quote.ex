defmodule Wanon.Quotes.Quote do
  use Ecto.Schema

  schema "quote" do
    field :creator, :binary
    has_many :entries, Wanon.Quotes.QuoteEntry
    timestamps(updated_at: false)
  end
end
