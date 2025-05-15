defmodule BellVault.Repo do
  use Ecto.Repo,
    otp_app: :bell_vault,
    adapter: Ecto.Adapters.Postgres
end
