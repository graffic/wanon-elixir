defmodule Wanon.Telegram.Updates do
  use GenStage
  require Logger
  alias Wanon.Telegram.HTTP

  def init(:ok) do
    {:producer, {0, 0}, dispatcher: GenStage.BroadcastDispatcher}
  end

  def start_link() do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_cast(:pending_demand, {offset, pending_demand}) do
    Logger.debug("Pending demand #{pending_demand}")
    produce_updates(offset, pending_demand)
  end

  def handle_demand(demand, {offset, pending_demand}) when demand > 0 do
    Logger.debug("Demand request #{demand} #{offset} #{pending_demand}")
    produce_updates(offset, demand + pending_demand)
  end

  defp produce_updates(offset, total_demand) do
    Logger.debug("Asking for data")

    HTTP.get_updates(offset)
    |> handle_response(offset, total_demand)
  end

  defp handle_response({:ok, %{"result" => []}}, offset, total_demand) do
    new_state([], offset, total_demand)
  end

  defp handle_response({:ok, %{"result" => result}}, offset, total_demand) do
    Logger.debug("Got #{length(result)} from #{total_demand}")

    pending_demand = max(0, total_demand - length(result))

    last_offset =
      result
      |> List.foldl([], &[&1["update_id"] | &2])
      |> List.foldl(offset, &max(&1, &2))

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
