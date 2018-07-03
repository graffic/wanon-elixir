defmodule StateServer do
  @moduledoc """
  Keeps the current state for response sequences.

  For a given path, there is a sequence of responses. After the sequence is finished
  the genserver will answer.
  """
  use GenServer

  defmodule StateEntry do
    defstruct replies: [], finished: false
  end


  @replies %{
    "/baseINTEGRATION/getUpdates" => [
      {:json, File.read!("integration/fixture.1.json")},
      {:json_block, "{\"result\":[]}", 5}
    ]
  }

  def start_link(replies \\ @replies) do
    GenServer.start_link(__MODULE__, replies)
  end

  def init(replies) do
    new_replies = replies
    |> Enum.map(fn {k, v} -> {k, %{remaining: v, finished: false}} end)
    |> Enum.into(%{})

    {:ok, new_replies}
  end

  def handle_call(path, _from, state) do
    case Map.fetch(state, path) do
      {:ok, value} -> next_state(state, value, path)
      :error -> {:reply, :notfound, state}
    end
  end

  defp next_state(state, %{remaining: [value]}, path) do
    {:reply, value, %{state | path => %{remaining: [value], finished: true}}}
  end

  defp next_state(state, %{remaining: [value|tail]}, path) do
    {:reply, value, %{state | path => %{remaining: tail, finished: false}}}
  end

  def request(pid, request_path) do
    GenServer.call(pid, request_path)
  end

end

defmodule TestServer do
  import Plug.Conn

  def init(state_server), do: state_server

  def call(conn, state_server) do
    state_server
    |> StateServer.request(conn.request_path)
    |> reply(conn)
  end

  defp reply(:notfound, conn) do
    conn |> send_resp(404, "")
  end

  defp reply({:json_block, body, duration}, conn) do
    Process.sleep(duration * 1000)
    reply({:json, body}, conn)
  end

  defp reply({:json, body}, conn) do
    conn
    |> put_resp_header("Content-Type", "application/json")
    |> send_resp(200, body)
  end
end

defmodule QuotesTest do
  use ExUnit.Case

  test "test basic interaction" do
    # ToDo
    # notify when stateserve finishes
    # Make test server and state server reusable
    {:ok, state} = StateServer.start_link()
    {:ok, server} = Plug.Adapters.Cowboy2.http(TestServer, state, port: 4242)
    Application.ensure_all_started(:wanon)
    receive do
      :ok -> nil
    end
  end
end
