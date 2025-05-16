defmodule BellFSWeb.Plugs.SetCurrentUser do
  @moduledoc """
  This plug is meant to be used in conjunction with the `guardian`
  library, specifically its pipeline defined in the
  `Guardian.Plug.EnsureAuthenticated` module.

  It sets the current user in the connection assigns, so that it can
  be accessed in the controllers and views.
  """

  @behaviour Plug

  alias BellFSWeb.Authentication

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    conn
    |> Plug.Conn.assign(:current_user, get_current_user(conn))
  end

  defp get_current_user(conn) do
    conn
    |> Authentication.Guardian.Plug.current_resource()
  end
end
