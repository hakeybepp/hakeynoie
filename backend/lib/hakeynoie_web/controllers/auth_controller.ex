defmodule HakeynoieWeb.AuthController do
  use HakeynoieWeb, :controller
  use AshAuthentication.Phoenix.Controller

  def success(conn, {:password, :register}, user, token) do
    conn
    |> put_status(:created)
    |> json(%{
      access_token: token,
      token_type: "bearer",
      user: render_user(user)
    })
  end

  def success(conn, {:password, :sign_in}, user, token) do
    conn
    |> put_status(:ok)
    |> json(%{
      access_token: token,
      token_type: "bearer",
      user: render_user(user)
    })
  end

  def failure(conn, {:password, :sign_in}, _reason) do
    conn
    |> put_status(:unauthorized)
    |> json(%{detail: "Invalid email or password"})
  end

  def failure(conn, {:password, :register}, reason) do
    if String.contains?(inspect(reason), "unique") do
      conn
      |> put_status(:conflict)
      |> json(%{detail: "Email already registered"})
    else
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{detail: "Registration failed"})
    end
  end

  def sign_out(conn, _params) do
    conn |> put_status(:ok) |> json(%{})
  end

  defp render_user(user) do
    %{
      id: user.id,
      email: to_string(user.email),
      full_name: user.full_name,
      is_admin: user.is_admin
    }
  end
end
