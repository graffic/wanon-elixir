defmodule Wanon.Quotes.RQuote do
  require Logger
  alias Wanon.Quotes.{Quote, QuoteEntry, Render}
  alias Wanon.Repo
  import Ecto.Query

  @telegram Application.get_env(:wanon, Wanon.Telegram.Client)

  def selector(%{"message" => %{"text" => text}}) do
    text
    |> String.downcase()
    |> String.starts_with?("/rquote")
  end

  def selector(_), do: false

  def execute(%{"message" => %{"chat" => %{"id" => chat_id}} = msg}) do
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
    entries_sort = from(e in QuoteEntry, order_by: e.order)

    from(
      q in Quote,
      where: q.chat_id == ^chat_id,
      offset: ^Enum.random(0..max(quotes - 1, 0)),
      preload: [entries: ^entries_sort],
      order_by: q.id,
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
