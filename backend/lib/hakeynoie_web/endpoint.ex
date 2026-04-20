defmodule HakeynoieWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :hakeynoie

  plug HakeynoieWeb.Plugs.Cors

  plug Plug.Static,
    at: "/",
    from: {:hakeynoie, "priv/static"},
    gzip: true,
    only: ~w(assets fonts images favicon.ico robots.txt vite.svg)

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug HakeynoieWeb.Router
end
