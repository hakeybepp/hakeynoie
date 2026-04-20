# Project Development Guidelines

## Stack

- **Backend**: Elixir / Phoenix (API mode) — `backend/`
- **Frontend**: React + TypeScript + Vite — `frontend/`
- **Database**: PostgreSQL 16

## Build & Run Commands

### Local Development (backend)
```bash
cd backend
mix deps.get          # install dependencies
mix ecto.setup        # create DB + run migrations
mix phx.server        # start server on port 4000
```

### Docker Development
- Start only database: `docker-compose up db`
- Start all services: `docker-compose up`
- Rebuild containers: `docker-compose build`
- Stop all services: `docker-compose down`

## Environment Configuration

### Environment Variables
- Local development uses `.env.local` file loaded by direnv
- Docker development shares the same `.env.local` file
- Production uses Fly.io secrets
- `DATABASE_URL` must use `postgresql://` prefix (not `postgresql+asyncpg://`)

## Testing

```bash
cd backend && mix test
cd backend && mix test --cover
```

## Linting & Code Style

```bash
cd backend && mix format          # auto-format
cd backend && mix format --check  # verify formatting (used in CI)
```

**Before every commit**, run `cd backend && mix format` to ensure all Elixir code is properly formatted. Do not commit unformatted code.

## Style Guidelines

### Elixir/Phoenix
- Follow standard Elixir conventions (mix format enforced)
- Use contexts (`Sacamer.Accounts`, `Sacamer.Bookings`) to encapsulate business logic
- Keep controllers thin — delegate to context modules
- Use Ecto changesets for validation
- Prefer pattern matching over conditionals
- Fail-fast on missing configuration (raise at startup)

### Architecture Guidelines
- When refactoring, if you remove code, you don't have to leave a comment behind
  explaining why it's gone.
- **Configuration**: Prefer to fail-fast and report issues rather than catch
  issues, default and move on
- **Dependencies**: If adding an Elixir library, add it to `mix.exs` and run
  `mix deps.get`; update the Dockerfile if it requires OS packages
