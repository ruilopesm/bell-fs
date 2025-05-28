defmodule BellFS.Structure do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Accounts.User
  alias BellFS.Structure.File

  alias BellFS.Security.{
    Confidentiality,
    Integrity,
    UserCompartment
  }

  ### Files

  @doc """
  Lists the files that a given user has access to.

  1. There's a `users_compartments` entry for the user.
  2. The file's confidentiality <= user's confidentiality level on such compartment.
  3. The file's integrity >= user's integrity level on such compartment.
  """
  def list_files(%User{username: username} = _current_user) do
    File
    |> join(:inner, [f], uc in UserCompartment, on: f.compartment_id == uc.compartment_id)
    |> join(:inner, [f, uc], uco in Confidentiality, on: uc.confidentiality_id == uco.id)
    |> join(:inner, [f, uc, uco], uin in Integrity, on: uc.integrity_id == uin.id)
    |> join(:inner, [f, uc, uco, uin], fco in Confidentiality, on: f.confidentiality_id == fco.id)
    |> join(:inner, [f, uc, uco, uin, fco], fin in Integrity, on: f.integrity_id == fin.id)
    |> where([f, uc, uco, uin, fco, fin], uc.username == ^username)
    |> where([f, uc, uco, uin, fco, fin], fco.level <= uco.level and fin.level >= uin.level)
    |> select([f, uc, uco, uin, fco, fin], f)
    |> Repo.all()
  end

  @doc """
  Returns `true` if the user can create a file, `false` otherwise.

  1. The user has access to such compartment.
  2. File's confidentiality level >= user's confidentiality level on such compartment.
  3. File's integrity level <= user's integrity level on such compartment.
  """
  def can_create_file?(%User{username: username} = _current_user, attrs) do
    compartment_id = attrs["compartment_id"]
    confidentiality_id = attrs["confidentiality_id"]
    integrity_id = attrs["integrity_id"]

    UserCompartment
    |> where([uc], uc.compartment_id == ^compartment_id)
    |> join(:inner, [uc], uco in Confidentiality, on: uc.confidentiality_id == uco.id)
    |> join(:inner, [uc, uco], uin in Integrity, on: uc.integrity_id == uin.id)
    |> join(:inner, [uc, uco, uin], fco in Confidentiality, on: fco.id == ^confidentiality_id)
    |> join(:inner, [uc, uco, uin, fco], fin in Integrity, on: fin.id == ^integrity_id)
    |> where([uc, uco, uin, fco, fin], uc.username == ^username)
    |> where([uc, uco, uin, fco, fin], fco.level >= uco.level and fin.level <= uin.level)
    |> Repo.exists?()
  end

  @doc """
  Creates a file.

  Assumes the user has already been checked for permissions.
  Returns `{:ok, %File{}}` on success, or `{:error, changeset}` on failure.
  """
  def create_file(attrs \\ %{}) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end
end
