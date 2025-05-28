defmodule BellFS.Security.UserCompartment do
  use BellFS, :schema

  alias BellFS.Accounts.User

  alias BellFS.Security.{
    Compartment,
    Confidentiality,
    Integrity
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(
    trusted
    username
    compartment_id
    confidentiality_id
    integrity_id
  )a
  @optional_fields ~w(trusted)a

  schema "users_compartments" do
    field :trusted, :boolean, default: false

    belongs_to :user, User,
      references: :username,
      foreign_key: :username,
      type: :string

    belongs_to :compartment, Compartment
    belongs_to :confidentiality, Confidentiality
    belongs_to :integrity, Integrity

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_compartment, attrs) do
    user_compartment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:username)
    |> foreign_key_constraint(:compartment_id)
    |> unique_constraint(
      :username,
      name: :unique_compartment_access,
      message: "user already has access to this compartment"
    )
    |> foreign_key_constraint(:confidentiality_id)
    |> foreign_key_constraint(:integrity_id)
  end

  def preloads, do: [
    :user,
    :compartment,
    :confidentiality,
    :integrity
  ]
end
