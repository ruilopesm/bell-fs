defmodule BellFS.Repo.Migrations.CreateCompartments do
  use Ecto.Migration

  def change do
    create table(:compartments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:compartments, [:name])
  end
end
