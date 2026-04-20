import Config

config :hakeynoie,
  ecto_repos: [Hakeynoie.Repo],
  ash_domains: [Hakeynoie.Accounts, Hakeynoie.Bookings]

config :hakeynoie, HakeynoieWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: HakeynoieWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Hakeynoie.PubSub

config :ash, :use_all_identities_in_manage_relationship?, false

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :hakeynoie, Hakeynoie.Mailer, adapter: Swoosh.Adapters.Local

import_config "#{config_env()}.exs"
