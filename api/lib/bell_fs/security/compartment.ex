defmodule BellFS.Security.Compartment do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name)a
  @optional_fields ~w()a

  schema "compartments" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(compartment, attrs) do
    compartment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
