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
    user_totp_uri = NimbleTOTP.otpauth_uri("BellFS:#{user.username}", user.totp_secret, issuer: "BellFS")
    qr_url = "https://api.qrserver.com/v1/create-qr-code/?data=#{URI.encode(user_totp_uri)}&size=200x200"
    %{
      user: UserJSON.data(user),
      user_totp_uri: user_totp_uri,
      user_totp_qr: qr_url
    }
  end
end
