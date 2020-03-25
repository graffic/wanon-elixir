defmodule QuotesTest do
  @moduledoc """
  Be careful with message ids, as in these tests the database is not emptied before each one.
  """
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

  test "Edit message" do
    # Make test server and state server reusable
    replies = %{
      "/baseINTEGRATION/getUpdates" => [
        {:json, File.read!("integration/fixture.2.edit.json")},
        {:json_block, "{\"result\":[]}", 5}
      ],
      "/baseINTEGRATION/sendMessage" => [
        # Add quote (we need to wait for this because if we don't wait
        # the test will stop without waiting for the getUpdates to finish)
        {:json, File.read!("integration/sendMessage.response.json")},
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
