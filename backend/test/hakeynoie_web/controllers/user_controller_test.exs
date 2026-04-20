defmodule HakeynoieWeb.UserControllerTest do
  use HakeynoieWeb.ConnCase

  import Hakeynoie.Test.Fixtures

  describe "index/2" do
    test "admin can list users", %{conn: conn} do
      _admin = create_admin(%{email: "adminlist@example.com"})
      _user1 = create_user(%{email: "listuser1@example.com"})
      _user2 = create_user(%{email: "listuser2@example.com"})

      auth_conn = login_conn(conn, "adminlist@example.com", default_password())

      response = get(auth_conn, "/api/users")
      assert response.status == 200

      body = Jason.decode!(response.resp_body)
      assert is_list(body)
      assert length(body) >= 3

      emails = Enum.map(body, & &1["email"])
      assert "listuser1@example.com" in emails
      assert "listuser2@example.com" in emails
    end

    test "regular user gets 403", %{conn: conn} do
      _user = create_user(%{email: "regularlist@example.com"})
      auth_conn = login_conn(conn, "regularlist@example.com", default_password())

      response = get(auth_conn, "/api/users")
      assert response.status == 403
    end

    test "unauthenticated gets 401", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/api/users")

      assert conn.status == 401
    end
  end

  describe "delete/2" do
    test "admin can soft-delete a user", %{conn: conn} do
      _admin = create_admin(%{email: "admindelete@example.com"})
      target = create_user(%{email: "todelete@example.com"})

      auth_conn = login_conn(conn, "admindelete@example.com", default_password())

      response = delete(auth_conn, "/api/users/#{target.id}")
      assert response.status == 204
    end

    test "soft-deleted user cannot log in", %{conn: conn} do
      _admin = create_admin(%{email: "adminsoftdel@example.com"})
      target = create_user(%{email: "softdeleted@example.com"})

      admin_conn = login_conn(conn, "adminsoftdel@example.com", default_password())

      # Delete the user
      delete_response = delete(admin_conn, "/api/users/#{target.id}")
      assert delete_response.status == 204

      # Try to sign in as the deleted user
      sign_in_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/sign_in", %{
          "user" => %{
            "email" => "softdeleted@example.com",
            "password" => default_password()
          }
        })

      assert sign_in_conn.status == 401
    end

    test "regular user cannot delete users", %{conn: conn} do
      _regular = create_user(%{email: "regulardel@example.com"})
      target = create_user(%{email: "targetdel@example.com"})

      auth_conn = login_conn(conn, "regulardel@example.com", default_password())

      response = delete(auth_conn, "/api/users/#{target.id}")
      assert response.status == 403
    end
  end
end
