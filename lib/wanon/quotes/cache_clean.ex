defmodule Wanon.Quotes.CacheClean do
  use GenServer
  alias Wanon.Quotes.CacheEntry
  require Logger
  import Ecto.Query, only: [from: 2]

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    schedule()
    {:ok, :ok}
  end

  def handle_info(:clean, :ok) do
    Logger.debug "Cleaning cache"
    from(e in CacheEntry, where: e.date < ^oldest())
    |> Wanon.Repo.delete_all

    schedule() 
    {:noreply, :ok}
  end

  defp schedule() do
    every = Application.get_env(:wanon, __MODULE__)[:every]
    Process.send_after(self(), :clean, every)
  end

  defp oldest() do
    keep = Application.get_env(:wanon, __MODULE__)[:keep]
    DateTime.to_unix(DateTime.utc_now()) - keep
  end
end