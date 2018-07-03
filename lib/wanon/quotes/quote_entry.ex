defmodule Wanon.Quotes.QuoteEntry do
  use Ecto.Schema

  schema "quote_entry" do
    field :order, :integer
    # Message https://core.telegram.org/bots/api#message
    field :message, :map
    belongs_to :quote, Wanon.Quotes.Quote
  end
end
