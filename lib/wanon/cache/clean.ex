defmodule Wanon.Cache.Clean do
  @moduledoc """
  Clean cache from time to time
  """
  use GenServer, start: {__MODULE__, :start_link, []}
  alias Wanon.Cache.CacheEntry
  require Logger
  import Ecto.Query, only: [from: 2]

  def start_link() do
    settings = Application.get_env(:wanon, __MODULE__)
    state = %{every: settings[:every], keep: settings[:keep]}

    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    schedule(state.every)
    {:ok, state}
  end

  def handle_info(:clean, state) do
    Logger.debug("Cleaning cache")

    from(e in CacheEntry, where: e.date < ^oldest(state.keep))
    |> Wanon.Repo.delete_all()

    schedule(state.every)
    {:noreply, state}
  end

  defp schedule(every) do
    Process.send_after(self(), :clean, every)
  end

  defp oldest(keep) do
    DateTime.to_unix(DateTime.utc_now()) - keep
  end
end
