defmodule Wanon.Dispatcher do
  use GenStage
  require Logger

  @commands [
    Wanon.Cache.Command,
    Wanon.Quotes.RQuote,
    Wanon.Quotes.AddQuote
  ]

  def start_link() do
    GenStage.start_link(Wanon.Dispatcher, :ok)
  end

  def init(:ok) do
    {:consumer, :ok,
     subscribe_to: [
       {
         Wanon.Telegram.Updates,
         max_demand: 10, selector: &selector/1
       }
     ]}
  end

  defp selector(%{"message" => %{"chat" => %{"id" => id}}}) do
    Application.get_env(:wanon, __MODULE__)
    |> MapSet.member?(id)
  end

  def handle_events([], _from, state) do
    {:noreply, [], state}
  end

  def handle_events([event | tail], from, state) do
    @commands
    |> Enum.filter(fn c -> c.selector(event) end)
    |> Enum.each(fn c -> c.execute(event) end)

    handle_events(tail, from, state)
  end
end
