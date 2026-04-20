defmodule HakeynoieWeb.Plugs.Cors do
  def init(opts), do: opts

  def call(conn, _opts) do
    origins = Application.get_env(:hakeynoie, :cors_origins, ["http://localhost:5173"])

    Corsica.call(
      conn,
      Corsica.init(
        origins: origins,
        allow_headers: :all,
        allow_methods: ["GET", "POST", "PATCH", "DELETE", "OPTIONS"],
        max_age: 86_400
      )
    )
  end
end
