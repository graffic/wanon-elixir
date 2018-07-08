defmodule Wanon.Telegram.HTTP do
  @behaviour Wanon.Telegram.Client
  require Logger

  def get_updates(offset \\ 0) do
    timeout = timeout()
    recv_timeout = timeout * 2 * 1000
    Logger.debug("GetUpdates offset:#{offset} timeouts:#{timeout} #{recv_timeout}")

    (url() <> "getUpdates")
    |> HTTPoison.get(
      [],
      recv_timeout: recv_timeout,
      params: [{"offset", offset}, {"timeout", timeout}]
    )
    |> get_body()
  end

  def get_me() do
    (url() <> "getMe")
    |> HTTPoison.get()
    |> get_body()
  end

  def reply(%{"chat" => %{"id" => id}, "message_id" => message_id}, text) do
    send_message(%{
      chat_id: id,
      text: text,
      reply_to_message_id: message_id
    })
  end

  def send_text(%{"chat" => %{"id" => id}}, text) do
    send_message(%{
      chat_id: id,
      text: text
    })
  end

  defp send_message(message) do
    headers = [{"Content-type", "application/json"}]
    {:ok, body} = Poison.encode(message)

    (url() <> "sendMessage")
    |> HTTPoison.post(body, headers)
  end

  defp get_body({:ok, response}) do
    {:ok, Poison.decode!(response.body)}
  end

  defp get_body({:error, error}) do
    {:error, error}
  end

  defp url() do
    config = Application.get_env(:wanon, __MODULE__)
    base_url = config[:base_url]
    token = config[:token]

    "#{base_url}#{token}/"
  end

  defp timeout() do
    Application.get_env(:wanon, __MODULE__)[:timeout]
  end
end
