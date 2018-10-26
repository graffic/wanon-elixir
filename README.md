[![Build Status](https://travis-ci.org/graffic/wanon-elixir.svg?branch=master)](https://travis-ci.org/graffic/wanon-elixir)
[![codecov](https://codecov.io/gh/graffic/wanon-elixir/branch/master/graph/badge.svg)](https://codecov.io/gh/graffic/wanon-elixir)
# Wanon

Telegram quote bot.

# Dev notes

## DB Server

You need a sql database. One way to do this is using a docker container with postgresql and expose it to your host.

`docker run --name wanondb -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 postgres:alpine`

This sets the password for the user `postgres`, it also creates a random volume for the database, so remember to clean it up. To open a psql you can use the same image:

`docker run -it --rm --link wanondb:wanondb postgres:alpine psql -h wanondb -U postgres`

## Launching wanon

Environment variables to set:
* `WANON_TELEGRAM_TOKEN` Telegram token wanon uses to get and send updates. There are two bots created (and therefore two tokens): production and development.
  * In dev mode it will use `dev.exs` and get it from the environment
  * In production mode, the default `config.exs` uses `${...}` so distillery will assign it from environment variables on start.
* `ERLANG_COOKIE` on distillery releases only, with or without container.
