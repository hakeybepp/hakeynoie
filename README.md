# Hakeynoie

A booking management app built with Elixir/Phoenix (API) and React/TypeScript.

## Stack

- **Backend**: Elixir / Phoenix (API mode) — `backend/`
- **Frontend**: React + TypeScript + Vite — `frontend/`
- **Database**: PostgreSQL 16

## Local Development

### Prerequisites (Ubuntu/WSL)

#### 1. Erlang & Elixir

```bash
wget -qO - https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc | sudo apt-key add -
echo "deb https://packages.erlang-solutions.com/ubuntu jammy contrib" | sudo tee /etc/apt/sources.list.d/erlang-solutions.list
sudo apt-get update
sudo apt-get install -y esl-erlang elixir
```

Verify: `elixir --version` should show 1.16+.

#### 2. PostgreSQL 16

```bash
sudo apt-get install -y postgresql-common
sudo /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y
sudo apt-get install -y postgresql-16
sudo service postgresql start
```

Create the dev database user (matches `config/dev.exs`):

```bash
sudo -u postgres psql -c "CREATE USER hakeynoie WITH PASSWORD 'hakeynoie_password' CREATEDB;"
```

PostgreSQL needs to be running whenever you develop locally. On WSL it doesn't start automatically — add this to your shell profile or run it each session:

```bash
sudo service postgresql start
```

### Backend

```bash
cd backend
mix local.hex --force && mix local.rebar --force   # first time only
mix setup           # deps + create DB + migrations
mix phx.server      # start API on port 4000
```

### Frontend

```bash
cd frontend
npm install
npm run dev         # start dev server on port 5173
```

### Docker

```bash
docker-compose up db       # database only
docker-compose up          # all services
docker-compose build       # rebuild containers
docker-compose down        # stop all
```

## Seed Data

Populate the database with sample development data:

```bash
cd backend && mix run priv/repo/seeds.exs
```

### Accounts

| Email | Password | Role |
|---|---|---|
| admin@example.com | Password123! | Admin |
| alice@example.com | Password123! | User |
| bob@example.com | Password123! | User |
| carol@example.com | Password123! | User |

### Bookings

10 bookings are created spread across past and future dates. All date ranges are
non-overlapping (required by the database constraint). The layout relative to the
day the script is run:

| Guest | Offset (days) | Type |
|---|---|---|
| alice | −50 → −44 | past |
| bob | −40 → −35 | past |
| carol | −30 → −25 | past |
| alice | −20 → −15 | past |
| bob | −5 → −1 | past (recent) |
| carol | +2 → +6 | upcoming |
| alice | +8 → +13 | upcoming |
| bob | +15 → +20 | future |
| admin | +22 → +27 | future |
| carol | +30 → +36 | future |

Past bookings cannot be edited or deleted (enforced by the app).

## Testing

```bash
cd backend && mix test
cd backend && mix test --cover
```

## Linting

```bash
cd backend && mix format          # auto-format
cd backend && mix format --check  # verify (CI)
```
