defmodule Wanon.Quotes.AddQuote do
  @moduledoc """
  Deals with /addquote command
  """
  use GenStage
  require Logger
  alias Wanon.Quotes.{Builder, Store, Consumer}

  @telegram Application.get_env(:wanon, Telegram.API)

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

  defp selector(_), do: false

  def handle_events(events, _from, state) do
    IO.inspect events
    Enum.each(events, &handle_event/1)
    {:noreply, [], state}
  end

  defp handle_event(%{"message" => %{"reply_to_message" => reply, "from" => from}}) do
    # Add quote
    %{"chat" => %{"id" => chat_id}, "message_id" => message_id} = reply

    Builder.build_from(chat_id, message_id, reply)
    |> Store.store(from, chat_id)

    # Notify about quote added
    @telegram.reply(reply, "procesado correctamente, siguienteeeeeee!!!!")
  end

  defp handle_event(event) do
    # Notify that you need to reply to a message
    @telegram.reply(event["message"], "Reply to a message to add a quote")
  end
end
