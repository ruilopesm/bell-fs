defmodule BellFS.Repo.Migrations.CreateCompartmentConflicts do
  use Ecto.Migration

  def change do
    create table(:compartment_conflicts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :compartment_a, references(:compartments, on_delete: :nothing, type: :binary_id)
      add :compartment_b, references(:compartments, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:compartment_conflicts, [:compartment_a])
    create index(:compartment_conflicts, [:compartment_b])
  end
end
