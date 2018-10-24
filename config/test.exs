use Mix.Config

config :wanon, ecto_repos: [Wanon.Repo]

config :wanon,
       Wanon.Repo,
       adapter: Ecto.Adapters.Postgres,
       hostname: "localhost",
       database: "wanon_test",
       username: "postgres",
       password: "mysecretpassword",
       pool: Ecto.Adapters.SQL.Sandbox

config :wanon,
       Wanon.Telegram.HTTP,
       timeout: 10,
       token: "token"

config :wanon,
       Wanon.Cache.Clean,
       every: 42,
       keep: 84

config :wanon, Wanon.Telegram.Client, Wanon.Telegram.Mock
