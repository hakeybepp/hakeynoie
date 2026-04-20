defmodule HakeynoieWeb.AuthControllerTest do
  use HakeynoieWeb.ConnCase

  import Hakeynoie.Test.Fixtures

  describe "register/2" do
    test "success returns 201 with access_token and user", %{conn: conn} do
      params = %{
        "user" => %{
          "email" => "newuser@example.com",
          "password" => "Password123!",
          "full_name" => "New User"
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/register", params)

      assert conn.status == 201
      body = Jason.decode!(conn.resp_body)
      assert Map.has_key?(body, "access_token")
      assert body["token_type"] == "bearer"
      assert body["user"]["email"] == "newuser@example.com"
      assert body["user"]["full_name"] == "New User"
      assert Map.has_key?(body["user"], "id")
    end

    test "duplicate email returns 409", %{conn: conn} do
      _existing = create_user(%{email: "dup@example.com"})

      params = %{
        "user" => %{
          "email" => "dup@example.com",
          "password" => "Password123!",
          "full_name" => "Another User"
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/register", params)

      assert conn.status == 409
      body = Jason.decode!(conn.resp_body)
      assert body["detail"] =~ "already registered"
    end

    test "missing required fields returns error", %{conn: conn} do
      params = %{
        "user" => %{
          "email" => "incomplete@example.com"
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/register", params)

      assert conn.status in [422, 400]
    end
  end

  describe "sign_in/2" do
    test "valid credentials returns 200 with access_token", %{conn: conn} do
      _user = create_user(%{email: "signin@example.com"})

      params = %{
        "user" => %{
          "email" => "signin@example.com",
          "password" => default_password()
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/sign_in", params)

      assert conn.status == 200
      body = Jason.decode!(conn.resp_body)
      assert Map.has_key?(body, "access_token")
      assert body["token_type"] == "bearer"
      assert body["user"]["email"] == "signin@example.com"
    end

    test "wrong password returns 401", %{conn: conn} do
      _user = create_user(%{email: "wrongpass@example.com"})

      params = %{
        "user" => %{
          "email" => "wrongpass@example.com",
          "password" => "WrongPassword!"
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/sign_in", params)

      assert conn.status == 401
      body = Jason.decode!(conn.resp_body)
      assert body["detail"] =~ "Invalid"
    end

    test "unknown email returns 401", %{conn: conn} do
      params = %{
        "user" => %{
          "email" => "nobody@example.com",
          "password" => "Password123!"
        }
      }

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post("/api/auth/user/password/sign_in", params)

      assert conn.status == 401
      body = Jason.decode!(conn.resp_body)
      assert body["detail"] =~ "Invalid"
    end
  end
end
