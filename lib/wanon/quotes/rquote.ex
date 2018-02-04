defmodule Wanon.Quotes.RQuote do
  use GenStage
  require Logger
  alias Wanon.Quotes.{Quote,Consumer}

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [{Consumer, selector: &selector/1}]}
  end

  defp selector(%{"message" => %{"text" => text}}) do
    text
    |> String.downcase() 
    |> String.starts_with?("/rquote")
  end

  defp selector(_), do: false

  def handle_events(events, _from, state) do
    Logger.debug("RQUOTE: #{inspect(events)}")
    Enum.each(events, &handle_event/1)
    {:noreply, [], state}
  end

  defp handle_event(event) do
    event
    |> get_quote()
    |> send_quote()
  end

  defp get_quote(%{"message" => %{"chat" => %{"id" => chat_id}}}) do
    alias Wanon.Repo
    import Ecto.Query

    quotes = from(q in Quote, where: q.chat_id == ^chat_id, select: count("*")) |> Repo.one
    
    offset = Enum.random(0..max(quotes-1, 0))
    the_quote = from(q in Quote,
      where: q.chat_id == ^chat_id,
      offset: ^offset,
      preload: [:entries],
      limit: 1) 
    |> Repo.one()
    {chat_id, the_quote}
  end

  defp send_quote({chat_id, the_quote}) do
    # ToDo
    IO.puts "ChatID #{chat_id} Quote #{inspect(the_quote)}"
  end
end