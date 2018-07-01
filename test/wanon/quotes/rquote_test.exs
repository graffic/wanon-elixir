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

  defp get_selector() do
    init = RQuote.init(:ok)
    {:consumer, :ok, subscribe_to: [{_, selector: selector}]} = init
    selector
  end

  test "Selector for unmatched messages" do
    refute get_selector().(%{"message" => %{"eggs" => "spam"}})
  end

  test "Selector for wrong message" do
    refute get_selector().(%{"message" => %{"text" => "potato"}})
  end

  test "Selector for right message" do
    assert get_selector().(%{"message" => %{"text" => "/rQuote"}})
  end

  test "Handle rquote with no quotes" do
    Telegram.Mock
    |> expect(:reply, fn %{"chat" => %{"id" => 42}}, "I'm empty. Add quotes to me." -> nil end)

    RQuote.handle_events([@msg], nil, :ok)
  end

  test "Get one quote" do
    alias Wanon.Quotes.{Quote, QuoteEntry}
    q = %Quote{
      creator: %{"first_name" => "Javier"},
      chat_id: 42,
      entries: [
        %QuoteEntry{
          order: 0,
          message: %{"text" => "spam"}
        }
      ]
    }
    Wanon.Repo.insert(q)
    Telegram.Mock
    |> expect(:send_text, fn 2, "test" -> nil end)
    RQuote.handle_events([@msg], nil, :ok)
  end
end
