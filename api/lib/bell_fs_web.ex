defmodule BellFSWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use BellFSWeb, :controller
      use BellFSWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: BellFSWeb.Layouts]

      import Plug.Conn

      action_fallback BellFSWeb.FallbackController

      unquote(verified_routes())
      unquote(response_helpers())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: BellFSWeb.Endpoint,
        router: BellFSWeb.Router,
        statics: BellFSWeb.static_paths()
    end
  end

  def response_helpers do
    quote do
      def not_found(conn) do
        conn
        |> put_status(:not_found)
        |> put_view(BellFSWeb.ErrorJSON)
        |> render(:"404")
      end

      def forbidden(conn) do
        conn
        |> put_status(:forbidden)
        |> put_view(BellFSWeb.ErrorJSON)
        |> render(:"403")
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
