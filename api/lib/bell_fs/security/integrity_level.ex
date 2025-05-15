defmodule BellFS.Security.IntegrityLevel do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name level)a
  @optional_fields ~w()a

  schema "integrity_levels" do
    field :name, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(integrity_level, attrs) do
    integrity_level
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
