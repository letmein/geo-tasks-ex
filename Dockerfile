FROM elixir:1.10.4-alpine as build

RUN mkdir /app
WORKDIR /app

RUN mix do local.hex --force, local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
COPY config config
COPY apps apps

RUN mix do deps.get --only $MIX_ENV, deps.compile, compile, release

FROM alpine:3.9 AS app

RUN apk add --update bash openssl postgresql-client

EXPOSE 4000
ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/app .
COPY entrypoint.sh .
COPY seed.sh .
RUN chown -R nobody: /app
USER nobody

ENV HOME=/app
CMD ["bash", "/app/entrypoint.sh"]
