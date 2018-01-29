use Mix.Config

config :wanon, ecto_repos: [Wanon.Repo]
config :wanon,
  Wanon.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "wanon_test",
  username: "postgres",
  password: "mysecretpassword",
  pool: Ecto.Adapters.SQL.Sandbox

config :wanon,
  Wanon.Telegram,
  timeout: 10,
  token: "token"