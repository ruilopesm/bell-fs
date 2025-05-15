defmodule BellFS.Repo.Migrations.CreateConfidentialityLevels do
  use Ecto.Migration

  def change do
    create table(:confidentiality_levels, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :level, :integer, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
