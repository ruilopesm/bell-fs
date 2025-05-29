defmodule BellFS.Security.CompartmentConflict do
  use BellFS, :schema

  alias BellFS.Security.Compartment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(compartment_a_id compartment_b_id)a
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
    |> foreign_key_constraint(:compartment_a_id)
    |> foreign_key_constraint(:compartment_b_id)
    |> unique_constraint(
      [:compartment_a_id, :compartment_b_id],
      name: :unique_compartment_conflict_sorted,
      message: "compartment conflict already exists"
    )
  end

  def preloads, do: [:compartment_a, :compartment_b]
end
