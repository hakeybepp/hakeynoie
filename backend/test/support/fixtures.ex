defmodule Hakeynoie.Test.Fixtures do
  @moduledoc """
  Test fixtures for creating users, bookings, and authenticated connections.
  """

  import Plug.Conn
  import Phoenix.ConnTest

  alias Hakeynoie.Accounts.User
  alias Hakeynoie.Bookings.Booking

  @endpoint HakeynoieWeb.Endpoint

  @default_password "Password123!"

  def default_password, do: @default_password

  def create_user(attrs \\ %{}) do
    unique = System.unique_integer([:positive])

    defaults = %{
      email: "user#{unique}@example.com",
      password: @default_password,
      full_name: "Test User #{unique}"
    }

    merged = Map.merge(defaults, attrs)

    User
    |> Ash.Changeset.for_create(:register_with_password, merged)
    |> Ash.create!(authorize?: false, domain: Hakeynoie.Accounts)
  end

  def create_admin(attrs \\ %{}) do
    user = create_user(attrs)

    # The User resource has no general :update action, only :soft_delete.
    # Use the Repo directly to set is_admin via a raw SQL update.
    Hakeynoie.Repo.query!(
      "UPDATE users SET is_admin = true WHERE id = $1",
      [Ecto.UUID.dump!(user.id)]
    )

    # Re-read the user to get the updated record
    Ash.get!(User, user.id, authorize?: false, domain: Hakeynoie.Accounts)
  end

  def create_booking(user, attrs \\ %{}) do
    today = Date.utc_today()

    defaults = %{
      check_in: Date.add(today, 10),
      check_out: Date.add(today, 15)
    }

    merged = Map.merge(defaults, attrs)

    Booking
    |> Ash.Changeset.for_create(:create, merged, actor: user, authorize?: false)
    |> Ash.create!(domain: Hakeynoie.Bookings, authorize?: false)
  end

  def create_past_booking(user, attrs \\ %{}) do
    today = Date.utc_today()

    defaults = %{
      check_in: Date.add(today, -20),
      check_out: Date.add(today, -15)
    }

    merged = Map.merge(defaults, attrs)

    Booking
    |> Ash.Changeset.for_create(:create, merged, actor: user, authorize?: false)
    |> Ash.create!(domain: Hakeynoie.Bookings, authorize?: false)
  end

  def login_conn(conn, email, password) do
    response =
      conn
      |> put_req_header("content-type", "application/json")
      |> post("/api/auth/user/password/sign_in", %{
        "user" => %{"email" => email, "password" => password}
      })

    body = Jason.decode!(response.resp_body)
    token = body["access_token"]

    # Reuse the same conn (to preserve sandbox ownership) but reset it and add auth header
    conn
    |> recycle()
    |> put_req_header("content-type", "application/json")
    |> put_req_header("authorization", "Bearer #{token}")
  end
end
