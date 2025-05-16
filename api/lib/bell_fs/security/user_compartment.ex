defmodule BellFS.Security.UserCompartment do
  use BellFS, :schema

  alias BellFS.Accounts.User

  alias BellFS.Security.{
    Compartment,
    ConfidentialityLevel,
    IntegrityLevel
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @required_fields ~w(
    username
    compartment_id
    confidentiality_level_id
    integrity_level_id
  )a
  @optional_fields ~w(trusted)a

  schema "users_compartments" do
    field :trusted, :boolean, default: false

    belongs_to :user, User,
      references: :username,
      foreign_key: :username,
      type: :string

    belongs_to :compartment, Compartment
    belongs_to :confidentiality_level, ConfidentialityLevel
    belongs_to :integrity_level, IntegrityLevel

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_compartment, attrs) do
    user_compartment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_required([:trusted])
    |> foreign_key_constraint(:username)
    |> foreign_key_constraint(:compartment_id)
    |> foreign_key_constraint(:confidentiality_level_id)
    |> foreign_key_constraint(:integrity_level_id)
  end
end
