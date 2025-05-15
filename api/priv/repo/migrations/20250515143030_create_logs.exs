defmodule BellFs.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :content, :text, null: false
      add :signature, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
