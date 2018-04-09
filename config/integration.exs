use Mix.Config

config :wanon, ecto_repos: [Wanon.Repo]
config :wanon,
  Wanon.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "wanon_test",
  username: "postgres",
  password: "mysecretpassword"

config :wanon,
  Wanon.Telegram,
  timeout: 10,
  token: "INTEGRATION",
  base_url: "http://localhost:4242/base"


config :wanon, Telegram.API, Telegram.Mock