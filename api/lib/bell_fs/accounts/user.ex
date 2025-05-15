defmodule BellFS.Accounts.User do
  use BellFS, :schema

  @primary_key {:username, :string, autogenerate: false}

  @required_fields ~w(username certificate)a
  @optional_fields ~w()a

  schema "users" do
    # PEM / X.509
    field :certificate, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
