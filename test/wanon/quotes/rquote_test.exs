defmodule RQuoteTest do
  use ExUnit.Case
  # import Ecto.Query
  import Mox
  alias Wanon.Quotes.RQuote

  @msg %{"message" => %{"chat" => %{"id" => 42}}}

  # Note: learn a about these two ways.
  setup :verify_on_exit!

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Wanon.Repo)
  end

  test "Selector for unmatched messages" do
    refute RQuote.selector(%{"message" => %{"eggs" => "spam"}})
  end

  test "Selector for wrong message" do
    refute RQuote.selector(%{"message" => %{"text" => "potato"}})
  end

  test "Selector for right message" do
    assert RQuote.selector(%{"message" => %{"text" => "/rQuote"}})
  end

  test "Handle rquote with no quotes" do
    Wanon.Telegram.Mock
    |> expect(:reply, fn %{"chat" => %{"id" => 42}}, "I'm empty. Add quotes to me." -> nil end)

    RQuote.execute(@msg)
  end

  test "Get one quote" do
    alias Wanon.Quotes.{Quote, QuoteEntry}

    q = %Quote{
      creator: %{"first_name" => "Javier"},
      chat_id: 42,
      entries: [
        %QuoteEntry{
          order: 1,
          message: %{"text" => "eggs", "from" => %{"username" => "python"}}
        },
        %QuoteEntry{
          order: 0,
          message: %{"text" => "spam", "from" => %{"username" => "monty"}}
        }
      ]
    }

    Wanon.Repo.insert(q)

    Wanon.Telegram.Mock
    |> expect(:send_text, fn %{"chat" => %{"id" => 42}}, "<monty> spam\n<python> eggs" -> nil end)

    RQuote.execute(@msg)
  end
end
