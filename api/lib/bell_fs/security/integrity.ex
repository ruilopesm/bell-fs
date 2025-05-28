defmodule BellFS.Security.Integrity do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name level)a
  @optional_fields ~w()a

  schema "integrities" do
    field :name, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(integrity, attrs) do
    integrity
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :integrities_name_index)
  end
end
