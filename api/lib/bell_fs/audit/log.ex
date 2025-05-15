defmodule BellFS.Audit.Log do
  use BellFS, :schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(signature content)a
  @optional_fields ~w()a

  schema "logs" do
    field :signature, :string
    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
