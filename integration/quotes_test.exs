defmodule StateServer do
  @moduledoc """
  Keeps the current state for response sequences
  """
  use GenServer, start:


  @replies %{
    "/baseINTEGRATION/getUpdates" => [
      {:json, "{\"result\":[]}"},
      {:json_block, "{\"result\":[]}", 5}
    ]
  }
  
  def start_link(replies \\ @replies) do
    GenServer.start_link(__MODULE__, replies)
  end

  def init(state), do: {:ok, state}

  def handle_call(path, _from, state) do
    case Map.fetch(state, path) do
      {:ok, [value]} -> {:reply, value, state}
      {:ok, [value|tail]} -> {:reply, value, %{state| path => tail}}
      :error -> {:reply, :notfound, state}
    end
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
    {:ok, state} = StateServer.start_link()
    {:ok, server} = Plug.Adapters.Cowboy2.http(TestServer, state, port: 4242)
    Application.ensure_all_started(:wanon)
    receive do
      :ok -> nil
    end
  end
end