defmodule Wanon.Quotes.Consumer do
  use GenStage

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    opts = [
      subscribe_to: [{
        Wanon.Telegram.GetUpdates,
        max_demand: 10,
        selector: &selector/1
      }],
      dispatcher: GenStage.BroadcastDispatcher
    ]
    {:producer_consumer, :ok, opts}
  end
  
  defp selector(%{"message" => %{"chat" => %{"id" => id}}}) do
    IO.puts "SELECTOR #{id}"
    Application.get_env(:wanon, __MODULE__)
    |> MapSet.member?(id)
  end

  def handle_events(events, _from, state) do
    {:noreply, events, state}
  end
end