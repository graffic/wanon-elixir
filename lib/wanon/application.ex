defmodule Wanon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    # List all child processes to be supervised
    children = [
      worker(Wanon.Repo, []),
      worker(Wanon.Telegram.GetUpdates, []),
      worker(Wanon.Quotes.Consumer, []),
      worker(Wanon.Quotes.Cache, []),
      worker(Wanon.Quotes.AddQuote, []),
      worker(Wanon.Quotes.RQuote, []),
      worker(Wanon.Quotes.CacheClean, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Wanon.Supervisor]
    Supervisor.start_link(children, opts)    
  end
end
