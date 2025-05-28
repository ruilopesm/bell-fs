defmodule BellFS.Security.Compartment do
  use BellFS, :schema

  alias BellFS.Structure.File

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name)a
  @optional_fields ~w()a

  schema "compartments" do
    field :name, :string

    has_many :files, File

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(compartment, attrs) do
    compartment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :compartments_name_index)
  end
end
