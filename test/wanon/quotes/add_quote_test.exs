defmodule AddQuoteTest do
  use ExUnit.Case
  import Mox
  import Ecto.Query
  alias Wanon.Quotes.AddQuote

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  test "Selector filters out unrecognized messages" do
    refute AddQuote.selector(%{})
  end

  test "Selector filters out other messages" do
    message = %{"message" => %{"text" => "Hello"}}
    refute AddQuote.selector(message)
  end

  test "Selector accepts addquote" do
    message = %{
      "message" => %{
        "text" => "/addquote",
        "chat" => %{"id" => 5},
        "message_id" => 6
      }
    }

    assert AddQuote.selector(message)
  end

  test "Add quote without a reply" do
    msg = %{
      "text" => "/addquote",
      "chat" => %{"id" => 5},
      "message_id" => 6
    }

    update = %{"message" => msg}

    Wanon.Telegram.Mock
    |> expect(:reply, fn ^msg, "Reply to a message to add a quote" -> nil end)

    AddQuote.execute(update)
  end

  test "Adds a quote, says ok" do
    reply = %{"chat" => %{"id" => 5}, "message_id" => 2}
    msg_from = %{"name" => "adds quote"}

    event = %{
      "message" => %{
        "text" => "/addquote",
        "chat" => %{"id" => 5},
        "message_id" => 6,
        "reply_to_message" => reply,
        "from" => msg_from
      }
    }

    Wanon.Telegram.Mock
    |> expect(:reply, fn ^reply, "procesado correctamente, siguienteeeeeee!!!!" -> nil end)

    AddQuote.execute(event)

    assert Wanon.Repo.one(
             from(q in Wanon.Quotes.Quote, where: q.creator == ^msg_from, select: count("*"))
           ) == 1
  end
end
