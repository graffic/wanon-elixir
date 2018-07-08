# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :wanon, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:wanon, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# YES, COMPILE TIME. For now it does the job.

config :wanon, ecto_repos: [Wanon.Repo]

config :wanon,
       Wanon.Repo,
       adapter: Ecto.Adapters.Postgres,
       database: System.get_env("WANON_DB_DATABASE"),
       username: System.get_env("WANON_DB_USERNAME"),
       password: System.get_env("WANON_DB_PASSWORD")

config :wanon,
       Wanon.Telegram.HTTP,
       timeout: String.to_integer(System.get_env("WANON_TELEGRAM_TIMEOUT") || "0"),
       token: System.get_env("WANON_TELEGRAM_TOKEN"),
       base_url: "https://api.telegram.org/bot"

config :wanon,
       Wanon.Dispatcher,
       MapSet.new([
         # Sandbox chat
         -11_802_333,
         # me
         77_629_777,
         # Irc revival
         -5_213_436,
         # Revival 2.0
         -125_151_221,
         # Revival 3.0
         -219_878_466
       ])

config :wanon,
       Wanon.Cache.Clean,
       every: 10 * 60 * 1000,
       # 2 days (yes, no Timex)
       keep: 60 * 60 * 24 * 2

config :wanon, Wanon.Telegram.Client, Wanon.Telegram.HTTP

import_config "#{Mix.env()}.exs"
