defmodule QuotesTest do
  use ExUnit.Case, async: false

  test "test basic interaction" do
    # Make test server and state server reusable
    replies = %{
      "/baseINTEGRATION/getUpdates" => [
        {:json, File.read!("integration/fixture.1.json")},
        {:json_block, "{\"result\":[]}", 5}
      ],
      "/baseINTEGRATION/sendMessage" => [
        # First rquote, no quotes
        {:json, File.read!("integration/sendMessage.response.json")},
        # Add quote without message
        {:json, File.read!("integration/sendMessage.response.json")},
        # Right add quote
        {:json, File.read!("integration/sendMessage.response.json")},
        # Rquote with quote
        {:json, File.read!("integration/sendMessage.response.json")},
        # Second addquote with special cases
        {:json, File.read!("integration/sendMessage.response.json")}
      ]
    }
    Wanon.Integration.TelegramAPI.start(replies)
    Application.ensure_all_started(:wanon)

    receive do
      :finished ->
        Application.stop(:wanon)
        Wanon.Integration.TelegramAPI.stop()
    end
  end
end
