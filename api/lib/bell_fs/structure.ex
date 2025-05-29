defmodule BellFS.Structure do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Accounts.User
  alias BellFS.Structure.File

  alias BellFS.Security
  alias BellFS.Security.{
    Confidentiality,
    Integrity,
    UserCompartment
  }

  ### Files

  @doc """
  Lists the files that a given user has access to.
  """
  def list_files(%User{} = current_user) do
    rows =
      current_user
      |> scoped_query(:read)
      |> select([f, uc, uco, uin, fco, fin], {f, uc})
      |> Repo.all()

    Enum.map(rows, fn {file, uc} ->
      file = Repo.preload(file, File.preloads())
      %{file: file, trusted: uc.trusted}
    end)
  end

  @doc """
  Returns `true` if the user can create a file, `false` otherwise.
  """
  def can_create_file?(%User{} = current_user, attrs) do
    current_user
    |> scoped_query(
      :create,
      compartment_id: attrs["compartment_id"],
      confidentiality_id: attrs["confidentiality_id"],
      integrity_id: attrs["integrity_id"]
    )
    |> Repo.exists?()
  end

  @doc """
  Creates a file, by returning `{:ok, %File{}}` on success, or `{:error, changeset}` on failure.

  Assumes the user has already been checked for permissions.
  """
  def create_file(attrs \\ %{}) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload_after_mutation(File.preloads())
  end

  @doc """
  Returns `true` if the user can read a file, `false` otherwise.
  """
  def can_read_file?(%User{} = current_user, id) do
    current_user
    |> scoped_query(:read, id: id)
    |> Repo.exists?()
  end

  @doc """
  Gets a file by its id, raising `Ecto.NoResultsError` if not found.

  Assumes the user has already been checked for permissions.
  """
  def get_file!(id) do
    File
    |> Repo.get!(id)
    |> Repo.preload(File.preloads())
  end

  @doc """
  Returns `true` if the user can update a file, `false` otherwise.
  """
  def can_update_file?(%User{} = current_user, id) do
    current_user
    |> scoped_query(:update, id: id)
    |> Repo.exists?()
  end

  def set_file_confidentiality(%File{} = file, confidentiality_name) do
    confidentiality = Security.get_confidentiality_by_name!(confidentiality_name)

    file
    |> File.changeset(%{confidentiality_id: confidentiality.id})
    |> Repo.update()
    |> Repo.preload_after_mutation(File.preloads())
  end

  def set_file_integrity(%File{} = file, integrity_name) do
    integrity = Security.get_integrity_by_name!(integrity_name)

    file
    |> File.changeset(%{integrity_id: integrity.id})
    |> Repo.update()
    |> Repo.preload_after_mutation(File.preloads())
  end

  @doc """
  Updates a file, by returning `{:ok, %File{}}` on success, or `{:error, changeset}` on failure.

  Assumes the user has already been checked for permissions.
  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
    |> Repo.preload_after_mutation(File.preloads())
  end

  @doc """
  Returns `true` if the user can delete a file, `false` otherwise.
  """
  def can_delete_file?(%User{} = current_user, id) do
    current_user
    |> scoped_query(:delete, id: id)
    |> Repo.exists?()
  end

  def delete_file(%File{} = file), do: Repo.delete(file)

  ### Helpers (BLP & Biba enforcement)

  false && @doc """
  A user is said to have permission to perform an action on a file if:

  1. There's a `users_compartments` entry for the user.
  2. The file's confidentiality <= user's confidentiality level on such compartment.
  3. The file's integrity >= user's integrity level on such compartment.
  """
  defp permission_filter(:read), do: dynamic([f, uc, uco, uin, fco, fin], fco.level <= uco.level and fin.level >= uin.level)

  false && @doc """
  A user is said to have permission to create a file if:

  1. There's a `users_compartments` entry for the user.
  2. The file's confidentiality >= user's confidentiality level on such compartment.
  3. The file's integrity <= user's integrity level on such compartment.
  """
  defp permission_filter(:create), do: dynamic([uc, uco, uin, fco, fin], fco.level >= uco.level and fin.level <= uin.level)

  false && @doc """
  A user is said to have permission to update a file if:

  1. There's a `users_compartments` entry for the user.
  2. The file's confidentiality >= user's confidentiality level on such compartment.
  3. The file's integrity <= user's integrity level on such compartment.
  """
  defp permission_filter(:update), do: dynamic([f, uc, uco, uin, fco, fin], fco.level >= uco.level and fin.level <= uin.level)

  false && @doc """
  A user is said to have permission to delete a file if:

  1. There's a `users_compartments` entry for the user where `trusted` is `true`.
  2. The file's confidentiality <= user's confidentiality level on such compartment.
  3. The file's integrity <= user's integrity level on such compartment.
  """
  defp permission_filter(:delete), do: dynamic([f, uc, uco, uin, fco, fin], uc.trusted == true and fco.level <= uco.level and fin.level <= uin.level)

  defp base_create_scope(
    %User{username: username},
    compartment_id,
    confidentiality_id,
    integrity_id
  ) do
    UserCompartment
    |> where([uc], uc.compartment_id == ^compartment_id)
    |> join(:inner, [uc], uco in Confidentiality, on: uc.confidentiality_id == uco.id)
    |> join(:inner, [uc, uco], uin in Integrity, on: uc.integrity_id == uin.id)
    |> join(:inner, [uc, uco, uin], fco in Confidentiality, on: fco.id == ^confidentiality_id)
    |> join(:inner, [uc, uco, uin, fco], fin in Integrity, on: fin.id == ^integrity_id)
    |> where([uc], uc.username == ^username)
  end

  defp base_file_scope(%User{username: username}, nil) do
    base_file_scope_internal(%User{username: username})
  end

  defp base_file_scope(%User{username: username}, id) do
    base_file_scope_internal(%User{username: username})
    |> where([f, uc, uco, uin, fco, fin], uc.username == ^username and f.id == ^id)
  end

  defp base_file_scope_internal(%User{username: username}) do
    File
    |> join(:inner, [f], uc in UserCompartment, on: f.compartment_id == uc.compartment_id)
    |> join(:inner, [f, uc], uco in Confidentiality, on: uc.confidentiality_id == uco.id)
    |> join(:inner, [f, uc, uco], uin in Integrity, on: uc.integrity_id == uin.id)
    |> join(:inner, [f, uc, uco, uin], fco in Confidentiality, on: f.confidentiality_id == fco.id)
    |> join(:inner, [f, uc, uco, uin, fco], fin in Integrity, on: f.integrity_id == fin.id)
    |> where([f, uc], uc.username == ^username)
  end

  defp scoped_query(user, action, extra \\ [])

  defp scoped_query(user, :create, extra) do
    base_create_scope(
      user,
      extra[:compartment_id],
      extra[:confidentiality_id],
      extra[:integrity_id]
    )
    |> where(^permission_filter(:create))
  end

  defp scoped_query(user, action, extra) do
    base_file_scope(user, extra[:id])
    |> where(^permission_filter(action))
  end
end
