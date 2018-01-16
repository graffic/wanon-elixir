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
    from(e in CacheEntry, where: e.date < 0)
    |> Wanon.Repo.delete_all

    schedule() 
    {:noreply, :ok}
  end

  defp schedule() do
    Process.send_after(self(), :clean, Application.get_env(:wanon, __MODULE__)[:every])
  end
end