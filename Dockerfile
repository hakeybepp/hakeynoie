# Stage 1: Build frontend
FROM node:24-alpine AS frontend-builder
WORKDIR /frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# Stage 2: Build Elixir release
FROM elixir:1.16-alpine AS backend-builder
RUN apk add --no-cache build-base git
WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY backend/mix.exs backend/mix.lock ./
RUN MIX_ENV=prod mix deps.get --only prod
RUN MIX_ENV=prod mix deps.compile

COPY backend/ ./

# Embed the frontend build into priv/static
COPY --from=frontend-builder /frontend/dist ./priv/static

RUN MIX_ENV=prod mix release

# Stage 3: Runtime image
FROM alpine:3.19
RUN apk add --no-cache libstdc++ openssl ncurses-libs

WORKDIR /app
RUN chown nobody /app

COPY --from=backend-builder --chown=nobody:root /app/_build/prod/rel/hakeynoie ./

USER nobody

ENV MIX_ENV=prod PHX_SERVER=true

CMD ["/app/bin/hakeynoie", "start"]
