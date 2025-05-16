defmodule BellFSWeb.AuthController do
  use BellFSWeb, :controller

  alias BellFS.Accounts
  alias BellFS.Accounts.User
  alias BellFS.Repo
  alias BellFSWeb.Authentication

  @doc """
  Registers a new user, by creating its entity in the database
  """
  def register(conn, %{"user" => params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      conn
      |> put_status(:created)
      |> render(:me, user: user)
    end
  end

  @doc """
  Logs in a user and returns it with two freshly generated JWT tokens:
  - An access token, valid for 15 minutes
  - A refresh token, valid for 30 days
  """
  def login(conn, %{"username" => username, "password" => password}) do
    with {:ok, %User{} = user} <- Accounts.authenticate_user(username, password),
         {:ok, access_token, _claims} <-
           Authentication.Guardian.encode_and_sign(user, %{},
             token_type: "access",
             ttl: {15, :minute}
           ),
         {:ok, refresh_token, _claims} <-
           Authentication.Guardian.encode_and_sign(user, %{},
             token_type: "refresh",
             ttl: {30, :day}
           ) do
      conn
      |> put_status(:ok)
      |> render(:login, user: user, access_token: access_token, refresh_token: refresh_token)
    end
  end

  def logout(conn, %{"refresh_token" => refresh_token}) do
    with {:ok, _claims} <- Authentication.Guardian.decode_and_verify(refresh_token),
         {:ok, _claims} <- Authentication.Guardian.revoke(refresh_token) do
      send_resp(conn, :no_content, "")
    end
  end

  @doc """
  Meant to be used by the client to generate a new access token
  using the refresh token.

  Also, revokes the old refresh token, so it can't be used again.

  As for the `login` action, it returns two freshly generated JWT tokens:
  - An access token, valid for 15 minutes
  - A refresh token, valid for 30 days
  """
  def refresh(conn, %{"refresh_token" => old_refresh_token}) do
    with {:ok, claims} <-
           Authentication.Guardian.decode_and_verify(old_refresh_token, %{"typ" => "refresh"}),
         {:ok, user} <- Authentication.Guardian.resource_from_claims(claims),
         {:ok, _} <- Authentication.Guardian.revoke(old_refresh_token),
         {:ok, access_token, _claims} <-
           Authentication.Guardian.encode_and_sign(user, %{},
             token_type: "access",
             ttl: {15, :minute}
           ),
         {:ok, refresh_token, _claims} <-
           Authentication.Guardian.encode_and_sign(user, %{},
             token_type: "refresh",
             ttl: {30, :day}
           ) do
      conn
      |> put_status(:created)
      |> render(:refresh, access_token: access_token, refresh_token: refresh_token)
    end
  end

  @doc """
  Assumes that user is authenticated, by successfully
  passing the authentication plug.

  Renders the user present in the connection assigns (`conn.assigns`).
  """
  def me(conn, _) do
    user = conn.assigns[:current_user]
    user = Repo.preload(user, [])

    conn
    |> put_status(:ok)
    |> render(:me, user: user)
  end
end
