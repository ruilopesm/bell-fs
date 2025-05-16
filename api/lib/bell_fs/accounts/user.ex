defmodule BellFS.Accounts.User do
  use BellFS, :schema

  @primary_key {:username, :string, autogenerate: false}

  @required_fields ~w(username certificate password)a
  @optional_fields ~w()a

  schema "users" do
    # PEM / X.509
    field :certificate, :string

    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> check_required(user.hashed_password)
    |> validate_password()
  end

  defp check_required(%Ecto.Changeset{} = changeset, hash) do
    case hash do
      nil ->
        changeset
        |> validate_required(@required_fields)

      _ ->
        changeset
        |> validate_required(@required_fields -- [:password])
    end
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12)
    |> hash_password()
  end

  defp hash_password(changeset) do
    password = get_change(changeset, :password)

    if password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end
end
