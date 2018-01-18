defmodule Wanon.Quotes.RQuote do
  use GenStage
  require Logger

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [{Wanon.Quotes.Consumer, selector: &selector/1}]}
  end

  defp selector(%{"message" => %{"text" => text}}) do
    text
    |> String.downcase() 
    |> String.starts_with?("/rquote")
  end

  def handle_events(events, _from, state) do
    Logger.debug("RQUOTE: #{inspect(events)}")
    {:noreply, [], state}
  end
end