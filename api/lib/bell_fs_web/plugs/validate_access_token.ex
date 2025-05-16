defmodule BellFSWeb.Plugs.ValidateAccessToken do
  @moduledoc """
  By using a pipeline, apart from keeping the code DRY, we can also
  ensure that all the controllers that use this pipeline will
  automatically have the `ensure_authenticated` plug run before
  their actions.

  This plug is meant to be used in conjunction with the `guardian`
  library, which is a JWT authentication library for Elixir.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :bell_fs,
    module: BellFSWeb.Authentication.Guardian,
    error_handler: BellFSWeb.Authentication.ErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource

  plug BellFSWeb.Plugs.SetCurrentUser
end
