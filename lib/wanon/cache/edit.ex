defmodule Wanon.Cache.Edit do
  @moduledoc """
  Edits a cached message
  """
  @behaviour Wanon.Command
  alias Wanon.Cache.CacheEntry
  import Ecto.Query, only: [from: 2]
  require Logger

  @impl true
  def selector(%{"edited_message" => _}), do: true

  @impl true
  def selector(_), do: false

  @impl true
  def execute(%{"edited_message" => message}) do
    from(c in CacheEntry, where: c.message_id == ^message["message_id"])
    |> Wanon.Repo.one()
    |> update(message)
  end

  defp update(nil, _), do: nil

  defp update(old, new) do
    old
    |> Ecto.Changeset.change(message: new)
    |> Wanon.Repo.update()
  end
end
