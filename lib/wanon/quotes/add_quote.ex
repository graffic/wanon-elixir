defmodule Wanon.Quotes.AddQuote do
  use GenStage
  require Logger
  alias Wanon.Quotes.{Builder, Store, Consumer}

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:consumer, :ok, subscribe_to: [{Consumer, selector: &selector/1}]}
  end

  defp selector(%{"message" => %{"text" => text}}) do
    text
    |> String.downcase() 
    |> String.starts_with?("/addquote")
  end

  def handle_events(events, _from, state) do
    Enum.each(events, &handle_event/1)
    {:noreply, [], state}
  end

  defp handle_event(%{"message" => %{"reply_to_message" => reply, "from" => from}}) do
    # Add quote
    %{"chat" => %{"id" => chat_id}, "message_id" => message_id} = reply
    Builder.build_from(chat_id, message_id, Poison.encode!(reply))
    |> Store.store(from)

    # Notify about quote added
    Wanon.Telegram.reply(reply, "procesado correctamente, siguienteeeeeee!!!!")
  end

  defp handle_event(event) do
    # Notify that you need to reply to a message
    Wanon.Telegram.reply(event["message"], "Reply to a message to add a quote")
  end
end