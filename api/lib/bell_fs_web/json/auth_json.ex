defmodule BellFSWeb.AuthJSON do
  @moduledoc false

  alias BellFSWeb.UserJSON

  def login(%{user: user, access_token: token, refresh_token: refresh_token}) do
    %{
      user: UserJSON.data(user),
      access_token: token,
      refresh_token: refresh_token
    }
  end

  def refresh(%{access_token: token, refresh_token: refresh_token}) do
    %{
      access_token: token,
      refresh_token: refresh_token
    }
  end

  def me(%{user: user}) do
    %{user: UserJSON.data(user)}
  end
end
