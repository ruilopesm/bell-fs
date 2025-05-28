defmodule BellFS.Repo do
  use Ecto.Repo, otp_app: :bell_fs, adapter: Ecto.Adapters.Postgres

  def preload_after_mutation(_, preloads \\ [])

  def preload_after_mutation({:ok, entity}, preloads) do
    {:ok, __MODULE__.preload(entity, preloads)}
  end

  def preload_after_mutation({:error, changeset}, _preloads) do
    {:error, changeset}
  end
end
