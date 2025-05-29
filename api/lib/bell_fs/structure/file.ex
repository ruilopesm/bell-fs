defmodule BellFS.Structure.File do
  use BellFS, :schema

  alias BellFS.Security.{
    Compartment,
    Confidentiality,
    Integrity
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(
    name
    content
    compartment_id
    confidentiality_id
    integrity_id
  )a
  @optional_fields ~w()a
  @editable_fields ~w(name content)a

  schema "files" do
    field :name, :string
    field :content, :string

    belongs_to :compartment, Compartment
    belongs_to :confidentiality, Confidentiality
    belongs_to :integrity, Integrity

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:compartment_id)
    |> foreign_key_constraint(:confidentiality_id)
    |> foreign_key_constraint(:integrity_id)
    |> unique_constraint(:name, name: :unique_file_per_compartment)
  end

  def editable_fields, do: @editable_fields

  def preloads, do: [
    :compartment,
    :confidentiality,
    :integrity
  ]
end
