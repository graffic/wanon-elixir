# FROM graffic/elixir:alpine-arm64v8 as build
FROM elixir:1.7.3-alpine as build
COPY mix.* /build/
COPY priv /build/priv/
COPY lib /build/lib/
COPY config /build/config/ 
COPY rel /build/rel/
ENV MIX_ENV=prod
WORKDIR /build
RUN mix local.hex --force &&\
    mix local.rebar --force &&\
    mix deps.get &&\
    mix release

# FROM arm64v8/alpine:latest
FROM alpine:3.8
COPY --from=build /build/_build/prod/rel/wanon /wanon
RUN apk add --no-cache bash openssl
ENV REPLACE_OS_VARS=true
WORKDIR /wanon
ENTRYPOINT [ "bin/wanon", "migrate_n_run" ]