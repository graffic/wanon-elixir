defmodule AddQuoteTest do
  use ExUnit.Case
  import Mox
  import Ecto.Query

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  defp get_selector() do
    init = Wanon.Quotes.AddQuote.init(:ok)
    {:consumer, :ok, subscribe_to: [{_, selector: selector}]} = init
    selector
  end

  test "Selector filters out unrecognized messages" do
    refute get_selector().(%{})
  end

  test "Selector filters out other messages" do
    message = %{"message" => %{"text" => "Hello"}}
    refute get_selector().(message)
  end

  test "Selector accepts addquote" do
    message = %{"message" => %{
      "text" => "/addquote",
      "chat" => %{"id" => 5},
      "message_id" => 6
    }}
    assert get_selector().(message)
  end


  test "Add quote without a reply" do
    msg = %{
      "text" => "/addquote",
      "chat" => %{"id" => 5},
      "message_id" => 6
    }
    update = %{"message" => msg}

    Telegram.Mock
    |> expect(:reply, fn ^msg, "Reply to a message to add a quote" -> nil end)

    Wanon.Quotes.AddQuote.handle_events([update], nil, :ok)
  end

  test "Adds a quote, says ok" do
    reply = %{"chat" => %{"id" => 5}, "message_id" => 2}
    msg_from = %{"name" => "adds quote"}
    events = [%{"message" => %{
      "text" => "/addquote",
      "chat" => %{"id" => 5},
      "message_id" => 6,
      "reply_to_message" => reply,
      "from" => msg_from
    }}]

    Telegram.Mock
    |> expect(:reply, fn ^reply, "procesado correctamente, siguienteeeeeee!!!!" -> nil end)

    Wanon.Quotes.AddQuote.handle_events(events, nil, :ok)

    assert Wanon.Repo.one(from q in Wanon.Quotes.Quote, where: q.creator == ^msg_from, select: count("*")) == 1
  end
end
