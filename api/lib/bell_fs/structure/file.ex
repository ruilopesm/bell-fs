defmodule BellFS.Structure.File do
  use BellFS, :schema

  alias BellFS.Uploaders.PersistentFile

  alias BellFS.Security.{
    Compartment,
    Confidentiality,
    Integrity
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(
    name
    compartment_id
    confidentiality_id
    integrity_id
  )a
  @optional_fields ~w()a
  @attachment_fields ~w(persistent)a

  schema "files" do
    field :name, :string
    field :persistent, PersistentFile.Type

    belongs_to :compartment, Compartment
    belongs_to :confidentiality, Confidentiality
    belongs_to :integrity, Integrity

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_attachments(attrs, @attachment_fields)
    |> validate_required(@required_fields ++ @attachment_fields)
    |> foreign_key_constraint(:compartment_id)
    |> foreign_key_constraint(:confidentiality_id)
    |> foreign_key_constraint(:integrity_id)
  end
end
