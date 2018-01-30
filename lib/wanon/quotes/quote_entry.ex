defmodule Wanon.Quotes.QuoteEntry do
  use Ecto.Schema

  schema "quote_entry" do
    field :order, :integer
    field :message, :binary
    belongs_to :quote, Wanon.Quotes.Quote
  end
end