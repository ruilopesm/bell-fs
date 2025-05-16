defmodule BellFSWeb.UserJSON do
  @moduledoc false

  alias BellFS.Accounts.User

  def certificate(%{certificate: certificate}) do
    %{certificate: certificate}
  end

  def data(%User{} = user) do
    %{
      username: user.username,
      certificate: user.certificate
    }
  end
end
