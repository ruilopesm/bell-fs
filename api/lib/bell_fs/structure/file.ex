defmodule BellFS.Structure.File do
  use BellFS, :schema

  alias BellFS.Security.{
    Compartment,
    ConfidentialityLevel,
    IntegrityLevel
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(
    name
    compartment_id
    confidentiality_level_id
    integrity_level_id
  )a
  @optional_fields ~w()a

  schema "files" do
    field :name, :string
    field :path, :string

    belongs_to :compartment, Compartment
    belongs_to :confidentiality_level, ConfidentialityLevel
    belongs_to :integrity_level, IntegrityLevel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:compartment_id)
    |> foreign_key_constraint(:confidentiality_level_id)
    |> foreign_key_constraint(:integrity_level_id)
  end
end
