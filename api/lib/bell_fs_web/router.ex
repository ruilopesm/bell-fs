defmodule BellFSWeb.Router do
  use BellFSWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :validate_access_token do
    plug BellFSWeb.Plugs.ValidateAccessToken
  end

  scope "/", BellFSWeb do
    pipe_through :api

    post "/login", AuthController, :login
    post "/register", AuthController, :register
    post "/logout", AuthController, :logout

    post "/refresh", AuthController, :refresh

    pipe_through :validate_access_token

    get "/me", AuthController, :me
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:bell_fs, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BellFSWeb.Telemetry
    end
  end
end
