defmodule BellFS.Repo.Migrations.CreateUsersCompartments do
  use Ecto.Migration

  def change do
    create table(:users_compartments, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :trusted, :boolean, default: false, null: false

      add :username,
          references(
            :users,
            column: :username,
            on_delete: :nothing,
            type: :string
          )

      add :compartment_id,
          references(
            :compartments,
            on_delete: :nothing,
            type: :binary_id
          )

      add :confidentiality_id,
          references(
            :confidentiality_levels,
            on_delete: :nothing,
            type: :binary_id
          )

      add :integrity_id,
          references(
            :integrity_levels,
            on_delete: :nothing,
            type: :binary_id
          )

      timestamps(type: :utc_datetime)
    end

    create index(:users_compartments, [:username])
    create index(:users_compartments, [:compartment_id])
    create index(:users_compartments, [:confidentiality_id])
    create index(:users_compartments, [:integrity_id])
  end
end
