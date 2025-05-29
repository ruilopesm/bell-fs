defmodule BellFS.Repo.Migrations.CreateConfidentialityLevels do
  use Ecto.Migration

  def change do
    create table(:confidentialities, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :level, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:confidentialities, [:name])
    create index(:confidentialities, [:level])
  end
end
