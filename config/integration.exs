use Mix.Config

config :wanon, ecto_repos: [Wanon.Repo]

config :wanon,
       Wanon.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: "wanon_test",
       username: "postgres",
       password: "mysecretpassword",
       hostname: "localhost"

config :wanon,
       Wanon.Telegram.HTTP,
       timeout: 10,
       token: "INTEGRATION",
       base_url: "http://localhost:4242/base"

config :wanon,
       Wanon.Cache.Clean,
       every: 400,
       # 2 days (yes, no Timex)
       keep: 60 * 60 * 24 * 2
