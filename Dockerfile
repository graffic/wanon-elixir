# FROM graffic/elixir:alpine-arm64v8 as build
FROM graffic/elixir:alpine-x86_64 as build
COPY mix.* /build/
COPY priv /build/priv/
COPY lib /build/lib/
COPY config /build/config/ 
COPY rel /build/rel/
ENV MIX_ENV=prod
WORKDIR /build
RUN mix deps.get &&\
    mix release

# FROM arm64v8/alpine:latest
FROM alpine:latest
COPY --from=build /build/_build/prod/rel/wanon /wanon
RUN apk add --no-cache bash
ENV REPLACE_OS_VARS=true
WORKDIR /wanon
ENTRYPOINT [ "bin/wanon", "migrate_n_run" ]