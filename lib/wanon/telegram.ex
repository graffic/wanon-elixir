defmodule Wanon.Telegram do
  require Logger

  def get_updates(offset \\ 0) do
    timeout = timeout()
    recv_timeout = (timeout*2) * 1000
    Logger.debug("GetUpdates offset:#{offset} timeouts:#{timeout} #{recv_timeout}")
    url() <> "getUpdates" 
    |> HTTPoison.get([], [recv_timeout: recv_timeout, params: [{"offset", offset}, {"timeout", timeout}]])
    |> get_body()
  end

  def get_me() do
    url() <> "getMe" 
    |> HTTPoison.get()
    |> get_body()
  end

  def reply(%{"chat" => %{"id" => id}, "message_id" => message_id}, text) do
    headers = [{"Content-type", "application/json"}]
    {:ok, body} = Poison.encode(%{
      "chat_id": id,
      "text": text,
      "reply_to_message_id": message_id
    })
    url() <> "sendMessage"
    |> HTTPoison.post(body, headers)
  end

  defp get_body({:ok, response}) do
    {:ok, Poison.decode!(response.body)}
  end

  defp get_body({:error, error}) do
    {:error, error}
  end

  defp url() do
    token = Application.get_env(:wanon, __MODULE__)[:token]
    "https://api.telegram.org/bot#{token}/"
  end

  defp timeout() do
    Application.get_env(:wanon, __MODULE__)[:timeout]
  end
end

defmodule Wanon.Telegram.GetUpdates do
  use GenStage
  require Logger

  def init(:ok) do
    {:producer, {0, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_cast(:pending_demand, {offset, pending_demand}) do
    Logger.debug "Pending demand #{pending_demand}"
    produce_updates(offset, pending_demand)
  end

  def handle_demand(demand, {offset, pending_demand}) when demand > 0 do
    Logger.debug "Demand request #{demand} #{offset} #{pending_demand}"
    produce_updates(offset, demand + pending_demand)
  end

  defp produce_updates(offset, total_demand) do
    Logger.debug "Asking for data"
    Wanon.Telegram.get_updates(offset)
    |> handle_response(offset, total_demand)
  end

  defp handle_response({:ok, %{"result" => []}}, offset, total_demand) do
    new_state([], offset, total_demand)
  end

  defp handle_response({:ok, %{"result" => result}}, offset, total_demand) do
    Logger.debug("Got #{length(result)} from #{total_demand}")

    pending_demand = max(0, total_demand - length(result))
    last_offset = result
    |> List.foldl([], &([&1["update_id"] | &2]))
    |> List.foldl(offset, &(max(&1, &2)))

    new_state(result, last_offset + 1, pending_demand)
  end

  defp handle_response({:error, error}, offset, total_demand) do
    Logger.error("#{inspect(error)}")
    new_state([], offset, total_demand)
  end

  defp new_state(result, offset, 0) do
    {:noreply, result, {offset, 0}}
  end

  defp new_state(result, offset, pending_demand) do
    GenServer.cast(self(), :pending_demand)
    {:noreply, result, {offset, pending_demand}}
  end
end

