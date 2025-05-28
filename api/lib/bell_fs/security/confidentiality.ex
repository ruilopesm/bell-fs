defmodule BellFS.Security.Confidentiality do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(name level)a
  @optional_fields ~w()a

  schema "confidentialities" do
    field :name, :string
    field :level, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(confidentiality, attrs) do
    confidentiality
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name, name: :confidentialities_name_index)
  end
end
