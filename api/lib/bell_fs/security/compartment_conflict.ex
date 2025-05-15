defmodule BellFS.Security.CompartmentConflict do
  use BellFS, :schema

  alias BellFS.Security.Compartment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w()a
  @optional_fields ~w()a

  schema "compartment_conflicts" do
    belongs_to :compartment_a, Compartment
    belongs_to :compartment_b, Compartment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(compartment_conflict, attrs) do
    compartment_conflict
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
