defmodule HakeynoieWeb.Router do
  use HakeynoieWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug HakeynoieWeb.Plugs.Authenticate
  end

  pipeline :admin do
    plug HakeynoieWeb.Plugs.Authenticate
    plug HakeynoieWeb.Plugs.RequireAdmin
  end

  pipeline :invite_check do
    plug HakeynoieWeb.Plugs.CheckInviteCode
  end

  scope "/api" do
    pipe_through [:api, :invite_check]
    auth_routes(HakeynoieWeb.AuthController, Hakeynoie.Accounts.User)
  end

  # Public: availability calendar
  scope "/api/bookings", HakeynoieWeb do
    pipe_through :api
    get "/availability", BookingController, :availability
  end

  # Admin: month view with guest info
  scope "/api/bookings", HakeynoieWeb do
    pipe_through [:api, :admin]
    get "/admin_month", BookingController, :admin_month
  end

  # Authenticated: list + create + update + delete + history
  scope "/api/bookings", HakeynoieWeb do
    pipe_through [:api, :authenticated]
    get "/", BookingController, :index
    post "/", BookingController, :create
    get "/history", BookingController, :history
    patch "/:id", BookingController, :update
    delete "/:id", BookingController, :delete
  end

  # Admin: users
  scope "/api/users", HakeynoieWeb do
    pipe_through [:api, :admin]
    get "/", UserController, :index
    delete "/:id", UserController, :delete
    patch "/:id/password", UserController, :reset_password
  end

  # Serve the frontend SPA for all non-API routes
  scope "/", HakeynoieWeb do
    get "/*path", PageController, :index
  end
end
