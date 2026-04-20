import Config

config :hakeynoie, Hakeynoie.Repo,
  username: "hakeynoie",
  password: "hakeynoie_password",
  hostname: "localhost",
  database: "hakeynoie",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :hakeynoie, HakeynoieWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  check_origin: false,
  debug_errors: true,
  secret_key_base: "dev_secret_key_base_placeholder_at_least_64_chars_xxxxxxxxxxxxxxxxxxxxxxxxxx"

config :hakeynoie,
       :token_signing_secret,
       "dev_token_signing_secret_at_least_32_chars_xxxxxxxxxxxxxxxx"

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
