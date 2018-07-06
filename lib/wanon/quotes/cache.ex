defmodule Wanon.Quotes.Cache do
  use GenStage
  alias Wanon.Quotes.CacheEntry
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [Wanon.Quotes.Consumer]}
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.map(&map/1)
    |> Enum.each(&Wanon.Repo.insert!/1)

    {:noreply, [], state}
  end

  defp map(%{"message" => message}) do
    Logger.debug("processing #{inspect(message)}")

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
