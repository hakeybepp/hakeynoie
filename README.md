# Hakeynoie

A booking management app built with Elixir/Phoenix (API) and React/TypeScript.

## Stack

- **Backend**: Elixir / Phoenix (API mode) — `backend/`
- **Frontend**: React + TypeScript + Vite — `frontend/`
- **Database**: PostgreSQL 16

## Local Development

### Backend

```bash
cd backend
mix deps.get        # install dependencies
mix ecto.setup      # create DB + run migrations
mix phx.server      # start API on port 4000
```

### Frontend

```bash
cd frontend
npm install
npm run dev         # start dev server
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
