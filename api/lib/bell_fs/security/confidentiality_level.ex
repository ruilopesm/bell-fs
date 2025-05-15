defmodule BellFS.Security.ConfidentialityLevel do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name level)a
  @optional_fields ~w()a

  schema "confidentiality_levels" do
    field :name, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(confidentiality_level, attrs) do
    confidentiality_level
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
