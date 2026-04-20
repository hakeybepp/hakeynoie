defmodule HakeynoieWeb.Plugs.CheckInviteCode do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method == "POST" and String.ends_with?(conn.request_path, "/register") do
      case Application.get_env(:hakeynoie, :invite_code) do
        nil ->
          conn

        expected ->
          provided = get_in(conn.body_params, ["user", "invite_code"])

          if provided == expected do
            conn
          else
            conn
            |> put_status(403)
            |> json(%{detail: "Invalid invite code"})
            |> halt()
          end
      end
    else
      conn
    end
  end
end
