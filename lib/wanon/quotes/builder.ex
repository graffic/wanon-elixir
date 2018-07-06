defmodule Wanon.Quotes.Builder do
  @moduledoc """
  Builds a quote from cache if possible.
  """
  import Ecto.Query
  alias Wanon.Quotes.CacheEntry

  def build_from(chat_id, message_id, backup_reply) do
    from(
      c in CacheEntry,
      where: c.chat_id == ^chat_id and c.message_id == ^message_id
    )
    |> Wanon.Repo.one()
    |> gather(backup_reply)
  end

  defp gather(nil, backup_reply) do
    [backup_reply]
  end

  defp gather(%CacheEntry{} = entry, _) do
    find_rest(entry, [])
  end

  defp find_rest(nil, result), do: result

  defp find_rest(%CacheEntry{reply_id: nil} = entry, result),
    do: [entry.message | result]

  defp find_rest(entry, rest) do
    next_entry =
      from(
        c in Wanon.Quotes.CacheEntry,
        where: c.chat_id == ^entry.chat_id and c.message_id == ^entry.reply_id
      )
      |> Wanon.Repo.one()

    find_rest(next_entry, [entry.message | rest])
  end
end
