defmodule Wanon.Cache.Add do
  @moduledoc """
  Caches all incoming updates through the dispatcher.
  """
  @behaviour Wanon.Command
  alias Wanon.Cache.CacheEntry
  require Logger

  def selector(%{"message" => _}), do: true
  def selector(_), do: false

  def execute(%{"message" => message}) do
    message
    |> map()
    |> Wanon.Repo.insert!()
  end

  defp map(message) do
    %CacheEntry{
      chat_id: message["chat"]["id"],
      message_id: message["message_id"],
      reply_id:
        case message do
          %{"reply_to_message" => %{"message_id" => reply_id}} -> reply_id
          _ -> nil
        end,
      date: message["date"],
      message: message
    }
  end
end
