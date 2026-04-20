FROM elixir:1.16-alpine

RUN apk add --no-cache build-base inotify-tools

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock* ./
RUN mix deps.get

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.migrate && mix phx.server"]
