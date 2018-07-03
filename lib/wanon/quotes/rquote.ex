defmodule Wanon.Quotes.RQuote do
  use GenStage
  require Logger
  alias Wanon.Quotes.{Quote, Consumer, QuoteEntry, Render}
  alias Wanon.Repo
  import Ecto.Query

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
    |> String.starts_with?("/rquote")
  end

  defp selector(_), do: false

  def handle_events(events, _from, state) do
    Logger.debug("RQUOTE: #{inspect(events)}")
    Enum.each(events, &handle_event/1)
    {:noreply, [], state}
  end

  defp handle_event(%{"message" => %{"chat" => %{"id" => chat_id}} = msg}) do
    chat_id
    |> count_quotes()
    |> get_quote()
    |> render_quote()
    |> send_quote(msg)
  end

  defp count_quotes(chat_id) do
    {
      from(q in Quote, where: q.chat_id == ^chat_id, select: count("*")) |> Repo.one(),
      chat_id
    }
  end

  defp get_quote({0, _}), do: :empty

  defp get_quote({quotes, chat_id}) do
    entries_sort = from e in QuoteEntry, order_by: e.order
    from(
      q in Quote,
      where: q.chat_id == ^chat_id,
      offset: ^Enum.random(0..max(quotes - 1, 0)),
      preload: [entries: ^entries_sort],
      limit: 1
    )
    |> Repo.one()
  end

  defp render_quote(:empty), do: :empty

  defp render_quote(the_quote) do
    Render.render(the_quote)
  end

  defp send_quote(:empty, msg) do
    @telegram.reply(msg, "I'm empty. Add quotes to me.")
  end

  defp send_quote(rendered, msg) do
    @telegram.send_text(msg, rendered)
  end

end
