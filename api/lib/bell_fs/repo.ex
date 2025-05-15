defmodule BellFS.Repo do
  use Ecto.Repo, otp_app: :bell_fs, adapter: Ecto.Adapters.Postgres
end
