defmodule Wanon.Quotes.Store do
  alias Wanon.Quotes.{Quote, QuoteEntry}

  def store(quotes, creator) do
    {entries, _} = Enum.map_reduce(quotes, 0, &map_entry/2)
    Wanon.Repo.insert %Quote{creator: Poison.encode!(creator), entries: entries}
  end

  defp map_entry(item, counter) do
    {%QuoteEntry{order: counter, message: Poison.encode!(item)}, counter + 1}
  end
end