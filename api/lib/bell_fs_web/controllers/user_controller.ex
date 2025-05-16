defmodule BellFSWeb.UserController do
  use BellFSWeb, :controller

  alias BellFS.Accounts

  def certificate(conn, %{"username" => username}) do
    user = Accounts.get_user!(username)

    conn
    |> put_status(:ok)
    |> render(:certificate, certificate: user.certificate)
  end
end
