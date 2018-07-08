defmodule Wanon.Quotes.AddQuote do
  @moduledoc """
  Deals with /addquote command
  """
  require Logger
  alias Wanon.Quotes.{Builder, Store}

  @telegram Application.get_env(:wanon, Wanon.Telegram.Client)

  def selector(%{"message" => %{"text" => text}}) do
    text
    |> String.downcase()
    |> String.starts_with?("/addquote")
  end

  def selector(_), do: false

  def execute(%{"message" => %{"reply_to_message" => reply, "from" => from}}) do
    # Add quote
    %{"chat" => %{"id" => chat_id}, "message_id" => message_id} = reply

    Builder.build_from(chat_id, message_id, reply)
    |> Store.store(from, chat_id)

    # Notify about quote added
    @telegram.reply(reply, "procesado correctamente, siguienteeeeeee!!!!")
  end

  def execute(event) do
    # Notify that you need to reply to a message
    @telegram.reply(event["message"], "Reply to a message to add a quote")
  end
end
