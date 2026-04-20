import Config

config :hakeynoie, Hakeynoie.Repo,
  username: "hakeynoie",
  password: "hakeynoie_password",
  hostname: System.get_env("DB_HOSTNAME", "localhost"),
  database: "hakeynoie_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :hakeynoie, HakeynoieWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "test_secret_key_base_placeholder_at_least_64_chars_xxxxxxxxxxxxxxxxxxxxxxxx"

config :hakeynoie, :token_signing_secret,
  "test_token_signing_secret_at_least_32_chars_xxxxxxxxxxxxxxxx"

config :hakeynoie, Hakeynoie.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning
config :phoenix, :plug_init_mode, :runtime
