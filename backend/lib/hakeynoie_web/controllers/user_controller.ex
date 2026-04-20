defmodule HakeynoieWeb.UserController do
  use HakeynoieWeb, :controller

  alias Hakeynoie.Accounts
  alias Hakeynoie.Accounts.User

  def index(conn, _params) do
    actor = conn.assigns.current_user

    case Ash.read(User, action: :read_with_bookings, actor: actor, domain: Accounts) do
      {:ok, users} ->
        json(conn, Enum.map(users, &render_user/1))

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{detail: "Internal server error"})
    end
  end

  def reset_password(conn, %{"id" => id, "password" => password}) do
    actor = conn.assigns.current_user

    case Ash.get(User, id, actor: actor, domain: Accounts) do
      {:ok, user} ->
        user
        |> Ash.Changeset.for_update(:reset_password, %{password: password}, actor: actor, domain: Accounts)
        |> Ash.update()
        |> case do
          {:ok, _} -> send_resp(conn, :no_content, "")
          {:error, _} -> conn |> put_status(:internal_server_error) |> json(%{detail: "Failed to reset password"})
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{detail: "User not found"})
    end
  end

  def delete(conn, %{"id" => id}) do
    actor = conn.assigns.current_user

    case Ash.get(User, id, actor: actor, domain: Accounts) do
      {:ok, user} ->
        user
        |> Ash.Changeset.for_update(:soft_delete, %{}, actor: actor, domain: Accounts)
        |> Ash.update()
        |> case do
          {:ok, _} -> send_resp(conn, :no_content, "")
          {:error, _} -> conn |> put_status(:internal_server_error) |> json(%{detail: "Failed to delete user"})
        end

      {:error, _} ->
        conn |> put_status(:not_found) |> json(%{detail: "User not found"})
    end
  end

  defp render_user(user) do
    %{
      id: user.id,
      email: to_string(user.email),
      full_name: user.full_name,
      is_admin: user.is_admin,
      created_at: user.created_at,
      bookings: Enum.map(user.bookings, fn b ->
        %{
          id: b.id,
          check_in: Date.to_iso8601(b.check_in),
          check_out: Date.to_iso8601(b.check_out),
          notes: b.notes
        }
      end)
    }
  end
end
