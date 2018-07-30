use Mix.Config

config :wanon,
       Wanon.Repo,
       adapter: Ecto.Adapters.Postgres,
       hostname: "localhost",
       database: "wanondev",
       username: "postgres",
       password: "mysecretpassword"
config :wanon,
       Wanon.Telegram.HTTP,
       timeout: 10,
       token: System.get_env("WANON_TELEGRAM_TOKEN"),
