defmodule StateServer do
  @moduledoc """
  Keeps the current state for response sequences.

  For a given path, there is a sequence of responses. After the sequence is finished
  the genserver will keep answering with the last one.
  """
  use GenServer

  defmodule State do
    defstruct replies: [], notify: nil
  end

  @replies %{
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

  def start_link(replies \\ @replies) do
    GenServer.start_link(__MODULE__, replies)
  end

  def init(replies) do
    {
      :ok,
      %State{
        replies:
          replies
          |> Enum.map(fn {k, v} -> {k, %{remaining: v, finished: false}} end)
          |> Enum.into(%{})
      }
    }
  end

  def handle_cast(from, state) do
    {:noreply, %{state | notify: from}}
  end

  def handle_call(path, _from, state) do
    case Map.fetch(state.replies, path) do
      {:ok, value} -> next_state(state, value, path)
      :error -> {:reply, :notfound, state}
    end
  end

  defp next_state(state, %{remaining: [value]}, path) do
    state = put_in(state.replies[path].finished, true)

    notify(
      state.notify,
      Enum.reduce_while(state.replies, true, fn
        {_, %{finished: true}}, _ -> {:cont, true}
        {_, %{finished: false}}, _ -> {:halt, false}
      end)
    )

    {:reply, value, state}
  end

  defp next_state(state, %{remaining: [value | tail]}, path) do
    new_state = put_in(state.replies[path].remaining, tail)
    {:reply, value, new_state}
  end

  defp notify(_, false), do: nil
  defp notify(pid, true), do: send(pid, :finished)

  def request(pid, request_path) do
    GenServer.call(pid, request_path)
  end

  def subscribe(pid) do
    GenServer.cast(pid, self())
  end
end

defmodule TestServer do
  import Plug.Conn

  def init(state_server), do: state_server

  def call(conn, state_server) do
    {:ok, body, _} = Plug.Conn.read_body(conn)
    IO.puts(body)

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
  use ExUnit.Case, async: false

  test "test basic interaction" do
    # Make test server and state server reusable
    {:ok, state} = StateServer.start_link()
    StateServer.subscribe(state)

    {:ok, _} = Plug.Adapters.Cowboy2.http(TestServer, state, port: 4242)
    Application.ensure_all_started(:wanon)

    receive do
      :finished -> nil
    end
  end
end
