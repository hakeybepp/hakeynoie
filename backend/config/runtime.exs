import Config

if config_env() in [:prod, :dev] do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise "DATABASE_URL environment variable is not set"

  # Strip Python asyncpg driver prefix if present
  database_url = String.replace(database_url, "postgresql+asyncpg://", "postgresql://")

  config :hakeynoie, Hakeynoie.Repo,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise "SECRET_KEY_BASE environment variable is not set"

  token_signing_secret =
    System.get_env("TOKEN_SIGNING_SECRET") ||
      raise "TOKEN_SIGNING_SECRET environment variable is not set"

  cors_origins =
    System.get_env("CORS_ORIGINS", "http://localhost:5173")
    |> String.split(",")
    |> Enum.map(&String.trim/1)

  config :hakeynoie, :token_signing_secret, token_signing_secret
  config :hakeynoie, :cors_origins, cors_origins

  if host = System.get_env("PHX_HOST") do
    config :hakeynoie, HakeynoieWeb.Endpoint, url: [host: host, port: 443, scheme: "https"]
  end

  if smtp_host = System.get_env("SMTP_HOST") do
    config :hakeynoie, Hakeynoie.Mailer,
      adapter: Swoosh.Adapters.SMTP,
      relay: smtp_host,
      port: String.to_integer(System.get_env("SMTP_PORT", "587")),
      username: System.get_env("SMTP_USERNAME"),
      password: System.get_env("SMTP_PASSWORD"),
      tls: :always,
      auth: :always

    config :hakeynoie, :from_email,
      System.get_env("FROM_EMAIL") || System.get_env("SMTP_USERNAME") ||
        raise("FROM_EMAIL or SMTP_USERNAME must be set when SMTP_HOST is configured")
  end

  if admin_email = System.get_env("ADMIN_EMAIL") do
    config :hakeynoie, :admin_email, admin_email
  end

  if invite_code = System.get_env("INVITE_CODE") do
    config :hakeynoie, :invite_code, invite_code
  end

  config :hakeynoie, HakeynoieWeb.Endpoint,
    http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],
    secret_key_base: secret_key_base
end
