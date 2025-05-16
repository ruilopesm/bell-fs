defmodule BellFSWeb.Authentication.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl true
  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{errors: %{detail: to_string(type)}})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
