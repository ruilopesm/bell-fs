defmodule BellFS.Repo do
  use Ecto.Repo, otp_app: :bell_fs, adapter: Ecto.Adapters.Postgres

  def after_insert_preload(_, preloads \\ [])

  def after_insert_preload({:ok, entity}, preloads) do
    {:ok, __MODULE__.preload(entity, preloads)}
  end

  def after_insert_preload({:error, changeset}, _preloads) do
    {:error, changeset}
  end
end
