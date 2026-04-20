defmodule HakeynoieWeb.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = AshAuthentication.Phoenix.Plug.load_from_bearer(conn, otp_app: :hakeynoie)

    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{detail: "Unauthorized"})
      |> halt()
    end
  end
end
