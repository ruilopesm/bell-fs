defmodule BellFSWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use BellFSWeb, :controller

  defguardp is_404(reason) when reason in [:not_found, :invalid_credentials, :invalid_totp_code]

  defguardp is_401(reason)
            when reason in [
                   :unauthorized,
                   :token_not_found,
                   :invalid_token,
                   :token_expired
                 ]

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: BellFSWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, reason}) when is_404(reason) do
    conn
    |> put_status(:not_found)
    |> put_view(json: BellFSWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, reason}) when is_401(reason) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: BellFSWeb.ErrorJSON)
    |> render(:"401")
  end
end
