defmodule BellFS.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :name, :string, null: false
      add :persistent, :string, null: false

      add :compartment_id,
          references(
            :compartments,
            on_delete: :nothing,
            type: :binary_id
          )

      add :confidentiality_id,
          references(
            :confidentialities,
            on_delete: :nothing,
            type: :binary_id
          )

      add :integrity_id,
          references(
            :integrities,
            on_delete: :nothing,
            type: :binary_id
          )

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:compartment_id])
    create index(:files, [:confidentiality_id])
    create index(:files, [:integrity_id])
  end
end
