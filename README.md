[![Build Status](https://travis-ci.org/graffic/wanon-elixir.svg?branch=master)](https://travis-ci.org/graffic/wanon-elixir)
[![Coverage Status](https://coveralls.io/repos/github/graffic/wanon-elixir/badge.svg?branch=master)](https://coveralls.io/github/graffic/wanon-elixir?branch=master)
# Wanon

Telegram quote bot.

# Dev notes

## DB Server

You need a sql database. One way to do this is using a docker container with postgresql and expose it to your host.

`docker run --name wanondb -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 postgres:alpine`

This sets the password for the user `postgres`, it also creates a random volume for the database, so remember to clean it up. To open a psql you can use the same image:

`docker run -it --rm --link wanondb:wanondb postgres:alpine psql -h wanondb -U postgres`
