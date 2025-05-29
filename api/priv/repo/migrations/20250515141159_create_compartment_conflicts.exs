defmodule BellFS.Repo.Migrations.CreateCompartmentConflicts do
  use Ecto.Migration

  def change do
    create table(:compartment_conflicts, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :compartment_a_id, references(:compartments, on_delete: :nothing, type: :binary_id)
      add :compartment_b_id, references(:compartments, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    execute("""
    CREATE UNIQUE INDEX unique_compartment_conflict_sorted
      ON compartment_conflicts (
        LEAST(compartment_a_id, compartment_b_id),
        GREATEST(compartment_a_id, compartment_b_id)
      );
    """)

    create index(:compartment_conflicts, [:compartment_a_id])
    create index(:compartment_conflicts, [:compartment_b_id])
  end
end
