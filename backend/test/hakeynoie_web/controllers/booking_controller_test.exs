defmodule HakeynoieWeb.BookingControllerTest do
  use HakeynoieWeb.ConnCase

  import Hakeynoie.Test.Fixtures

  describe "availability/2" do
    test "returns list of occupied date strings for a month", %{conn: conn} do
      user = create_user()
      today = Date.utc_today()
      month = "#{today.year}-#{String.pad_leading(to_string(today.month), 2, "0")}"

      # Create a booking that overlaps with this month
      check_in = %{today | day: 5}
      check_out = %{today | day: 8}

      _booking = create_booking(user, %{check_in: check_in, check_out: check_out})

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/api/bookings/availability?month=#{month}")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert is_list(body)
      # Occupied days should include day 5, 6, 7 (check_out day not included)
      assert Enum.member?(body, Date.to_iso8601(check_in))
    end

    test "returns empty list when no bookings exist for month", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/api/bookings/availability?month=2099-01")

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert body == []
    end

    test "returns bad request for missing month param", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/api/bookings/availability")

      assert conn.status == 400
    end
  end

  describe "index/2" do
    test "unauthenticated returns 401", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/api/bookings")

      assert conn.status == 401
    end

    test "user sees only own bookings, not other users'", %{conn: conn} do
      user1 = create_user(%{email: "user1@example.com"})
      user2 = create_user(%{email: "user2@example.com"})

      _booking1 = create_booking(user1)
      _booking2 = create_booking(user2, %{check_in: Date.add(Date.utc_today(), 20), check_out: Date.add(Date.utc_today(), 25)})

      auth_conn = login_conn(conn, user1.email |> to_string(), default_password())

      response = get(auth_conn, "/api/bookings")
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert is_list(body)
      assert length(body) == 1
      assert hd(body)["user_id"] == user1.id
    end

    test "admin sees all bookings", %{conn: conn} do
      admin = create_admin(%{email: "admin@example.com"})
      user = create_user(%{email: "regularuser@example.com"})

      _booking1 = create_booking(admin)
      _booking2 = create_booking(user, %{check_in: Date.add(Date.utc_today(), 20), check_out: Date.add(Date.utc_today(), 25)})

      auth_conn = login_conn(conn, "admin@example.com", default_password())

      response = get(auth_conn, "/api/bookings")
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert is_list(body)
      assert length(body) == 2
    end
  end

  describe "create/2" do
    test "user creates booking successfully, returns 201", %{conn: conn} do
      user = create_user(%{email: "creator@example.com"})
      auth_conn = login_conn(conn, "creator@example.com", default_password())

      today = Date.utc_today()

      params = %{
        "check_in" => Date.to_iso8601(Date.add(today, 30)),
        "check_out" => Date.to_iso8601(Date.add(today, 35))
      }

      response = post(auth_conn, "/api/bookings", params)
      assert response.status == 201

      body = Jason.decode!(response.resp_body)
      assert body["user_id"] == user.id
      assert Map.has_key?(body, "check_in")
      assert Map.has_key?(body, "check_out")
    end

    test "unauthenticated returns 401", %{conn: conn} do
      today = Date.utc_today()

      params = %{
        "check_in" => Date.to_iso8601(Date.add(today, 30)),
        "check_out" => Date.to_iso8601(Date.add(today, 35))
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/bookings", params)

      assert conn.status == 401
    end

    test "overlapping dates returns 409", %{conn: conn} do
      user = create_user(%{email: "overlap@example.com"})
      today = Date.utc_today()

      # Create a booking for days 40-50
      _existing = create_booking(user, %{
        check_in: Date.add(today, 40),
        check_out: Date.add(today, 50)
      })

      auth_conn = login_conn(conn, "overlap@example.com", default_password())

      # Try to create overlapping booking
      params = %{
        "check_in" => Date.to_iso8601(Date.add(today, 42)),
        "check_out" => Date.to_iso8601(Date.add(today, 48))
      }

      response = post(auth_conn, "/api/bookings", params)
      assert response.status == 409

      body = Jason.decode!(response.resp_body)
      assert body["detail"] =~ "overlap"
    end

    test "admin creates booking for another user with user_id param", %{conn: conn} do
      _admin = create_admin(%{email: "adminbook@example.com"})
      target_user = create_user(%{email: "targetuser@example.com"})

      auth_conn = login_conn(conn, "adminbook@example.com", default_password())

      today = Date.utc_today()

      params = %{
        "check_in" => Date.to_iso8601(Date.add(today, 60)),
        "check_out" => Date.to_iso8601(Date.add(today, 65)),
        "user_id" => target_user.id
      }

      response = post(auth_conn, "/api/bookings", params)
      assert response.status == 201

      body = Jason.decode!(response.resp_body)
      assert body["user_id"] == target_user.id
    end
  end

  describe "update/2" do
    test "user can update own future booking", %{conn: conn} do
      user = create_user(%{email: "updater@example.com"})
      booking = create_booking(user)

      auth_conn = login_conn(conn, "updater@example.com", default_password())

      today = Date.utc_today()

      params = %{
        "check_in" => Date.to_iso8601(Date.add(today, 50)),
        "check_out" => Date.to_iso8601(Date.add(today, 55))
      }

      response = patch(auth_conn, "/api/bookings/#{booking.id}", params)
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert body["check_in"] == Date.to_iso8601(Date.add(today, 50))
    end

    test "user cannot update another user's booking (returns 404 or 403)", %{conn: conn} do
      owner = create_user(%{email: "owner@example.com"})
      _other = create_user(%{email: "other@example.com"})

      booking = create_booking(owner)

      auth_conn = login_conn(conn, "other@example.com", default_password())

      params = %{
        "notes" => "Trying to hijack"
      }

      response = patch(auth_conn, "/api/bookings/#{booking.id}", params)
      assert response.status in [403, 404]
    end

    test "cannot update past booking", %{conn: conn} do
      user = create_user(%{email: "pastupdate@example.com"})
      booking = create_past_booking(user)

      auth_conn = login_conn(conn, "pastupdate@example.com", default_password())

      params = %{
        "notes" => "Trying to update past"
      }

      response = patch(auth_conn, "/api/bookings/#{booking.id}", params)
      assert response.status in [409, 422, 400, 403, 404]
    end
  end

  describe "delete/2" do
    test "user can delete own future booking", %{conn: conn} do
      user = create_user(%{email: "deleter@example.com"})
      booking = create_booking(user)

      auth_conn = login_conn(conn, "deleter@example.com", default_password())

      response = delete(auth_conn, "/api/bookings/#{booking.id}")
      assert response.status == 204
    end

    test "user cannot delete another user's booking", %{conn: conn} do
      owner = create_user(%{email: "bookowner@example.com"})
      _other = create_user(%{email: "notowner@example.com"})

      booking = create_booking(owner)

      auth_conn = login_conn(conn, "notowner@example.com", default_password())

      response = delete(auth_conn, "/api/bookings/#{booking.id}")
      assert response.status in [403, 404]
    end

    test "cannot delete past booking", %{conn: conn} do
      user = create_user(%{email: "pastdelete@example.com"})
      booking = create_past_booking(user)

      auth_conn = login_conn(conn, "pastdelete@example.com", default_password())

      response = delete(auth_conn, "/api/bookings/#{booking.id}")
      assert response.status in [409, 422, 400, 403, 404, 500]
    end
  end

  describe "history/2" do
    test "user sees own history entries only", %{conn: conn} do
      user1 = create_user(%{email: "histuser1@example.com"})
      _user2 = create_user(%{email: "histuser2@example.com"})

      # Create bookings (which generate history records)
      auth_conn1 = login_conn(conn, "histuser1@example.com", default_password())
      auth_conn2 = login_conn(conn, "histuser2@example.com", default_password())

      today = Date.utc_today()

      post(auth_conn1, "/api/bookings", %{
        "check_in" => Date.to_iso8601(Date.add(today, 70)),
        "check_out" => Date.to_iso8601(Date.add(today, 75))
      })

      post(auth_conn2, "/api/bookings", %{
        "check_in" => Date.to_iso8601(Date.add(today, 76)),
        "check_out" => Date.to_iso8601(Date.add(today, 80))
      })

      response = get(auth_conn1, "/api/bookings/history")
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert is_list(body)
      assert length(body) >= 1
      # All history entries should belong to user1
      assert Enum.all?(body, fn h -> h["user_id"] == user1.id end)
    end

    test "admin sees all history entries", %{conn: conn} do
      _admin = create_admin(%{email: "adminhistory@example.com"})
      user1 = create_user(%{email: "histregular1@example.com"})
      user2 = create_user(%{email: "histregular2@example.com"})

      auth_conn1 = login_conn(conn, "histregular1@example.com", default_password())
      auth_conn2 = login_conn(conn, "histregular2@example.com", default_password())
      admin_conn = login_conn(conn, "adminhistory@example.com", default_password())

      today = Date.utc_today()

      post(auth_conn1, "/api/bookings", %{
        "check_in" => Date.to_iso8601(Date.add(today, 81)),
        "check_out" => Date.to_iso8601(Date.add(today, 86))
      })

      post(auth_conn2, "/api/bookings", %{
        "check_in" => Date.to_iso8601(Date.add(today, 87)),
        "check_out" => Date.to_iso8601(Date.add(today, 91))
      })

      response = get(admin_conn, "/api/bookings/history")
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert is_list(body)
      # Admin should see entries for both users
      user_ids = Enum.map(body, & &1["user_id"]) |> Enum.uniq()
      assert user1.id in user_ids
      assert user2.id in user_ids
    end
  end
end
