defmodule BellFSWeb.Authentication.Guardian do
  @moduledoc """
  Module responsible for user authentication and authorization interactions
  regarding `guardian` library.
  """
  use Guardian, otp_app: :bell_fs

  alias BellFS.Accounts
  alias BellFS.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, user.username}
  end

  def resource_from_claims(%{"sub" => username}) do
    case Accounts.get_user(username) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
    end
  end
end
