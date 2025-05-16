defmodule BellFS.Accounts do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Accounts.User

  ### User

  @doc """
  Creates a user

  All of this is done in a transaction, so if any of the operations
  fail, the entire transaction is rolled back.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, user} -> {:ok, user}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Authenticates a user by username and password.

  If there is no user or the user doesn't have a password, we
  call `Argon2.no_user_verify()` to prevent timing attacks.
  """
  def authenticate_user(username, password) do
    get_user(username)
    |> maybe_authenticate_user(password)
  end

  defp maybe_authenticate_user(nil, _) do
    Argon2.no_user_verify()
    {:error, :invalid_credentials}
  end

  defp maybe_authenticate_user(%User{} = user, password) do
    if Argon2.verify_pass(password, user.hashed_password) do
      {:ok, user}
    else
      Argon2.no_user_verify()
      {:error, :invalid_credentials}
    end
  end

  @doc """
  Gets a single user by username (it's primary key in the database).

  Returns `nil` if the user does not exist.
  """
  def get_user(username), do: Repo.get(User, username)

  @doc """
  Gets a single user by username (it's primary key in the database).

  Raises `Ecto.NoResultsError` if the user does not exist.
  """
  def get_user!(username), do: Repo.get!(User, username)
end
