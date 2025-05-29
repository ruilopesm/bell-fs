defmodule BellFS.Security do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Accounts.User
  alias BellFS.Structure.File
  alias BellFS.Security.{
    Compartment,
    CompartmentConflict,
    Confidentiality,
    Integrity,
    UserCompartment
  }

  ### Compartments

  def list_compartments(%User{username: username} = _current_user) do
    rows =
      Compartment
      |> join(:inner, [c], uc in UserCompartment, on: uc.compartment_id == c.id)
      |> where([c, uc], uc.username == ^username)
      |> select([c, uc], {c, uc})
      |> Repo.all()

    Enum.map(rows, fn {compartment, uc} ->
      uc = Repo.preload(uc, UserCompartment.preloads())
      %{compartment: compartment, uc: uc}
    end)
  end

  def get_compartment!(id), do: Repo.get!(Compartment, id)

  def get_compartment_by_name!(name) do
    Compartment
    |> where([c], c.name == ^name)
    |> Repo.one!()
  end

  def create_compartment(attrs) do
    %Compartment{}
    |> Compartment.changeset(attrs)
    |> Repo.insert()
  end

  def is_user_trusted_in_compartment?(%User{username: username} = _current_user, compartment) do
    UserCompartment
    |> where([uc], uc.username == ^username and uc.compartment_id == ^compartment.id)
    |> where([uc], uc.trusted == true)
    |> Repo.exists?()
  end

  def add_user_to_compartment(attrs \\ %{}) do
    %UserCompartment{}
    |> UserCompartment.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload_after_mutation(UserCompartment.preloads())
  end

  def remove_user_from_compartment(compartment_id, username) do
    UserCompartment
    |> where([uc], uc.compartment_id == ^compartment_id and uc.username == ^username)
    |> Repo.one()
    |> case do
      nil -> {:error, :not_found}
      user_compartment -> Repo.delete(user_compartment)
    end
  end

  ### Levels

  def list_confidentialities do
    Confidentiality
    |> order_by([c], c.level)
    |> Repo.all()
  end

  def get_confidentiality_by_name!(name) do
    Confidentiality
    |> where([c], c.name == ^name)
    |> Repo.one!()
  end

  def create_confidentiality(attrs \\ %{}) do
    %Confidentiality{}
    |> Confidentiality.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  1. Files can lower their condfidentiality level via trusted users with a level >= file's confidentiality level.
  (expurge)

  2. Files can raise their condfidentiality level via any trusted user.
  (elevate)
  """
  def can_update_file_confidentiality?(
    %User{username: username} = _current_user,
    file_id,
    confidentiality_name
  ) do
    UserCompartment
    |> where([uc], uc.username == ^username and uc.trusted == true)
    |> join(:inner, [uc], f in File, on: f.compartment_id == uc.compartment_id and f.id == ^file_id)
    |> join(:inner, [uc, f], old in Confidentiality, on: old.id == f.confidentiality_id)
    |> join(:inner, [uc, f, old], new in Confidentiality, on: new.name == ^confidentiality_name)
    |> join(:inner, [uc, f, old, new], uco in Confidentiality, on: uco.id == uc.confidentiality_id)
    |> where([uc, f, old, new, uco],
      (new.level < old.level and uco.level >= old.level) or
      (new.level > old.level)
    )
    |> select([uc, f, old, new, uco], uc.id)
    |> Repo.exists?()
  end

  @doc """
  1. Files can raise their integrity level via trusted users with a level >= file's integrity level.
  (fortify)

  2. Files can lower their integrity level via any trusted user.
  (deteriorate)
  """
  def can_update_file_integrity?(
    %User{username: username} = _current_user,
    file_id,
    integrity_name
  ) do
    UserCompartment
    |> where([uc], uc.username == ^username and uc.trusted == true)
    |> join(:inner, [uc], f in File, on: f.compartment_id == uc.compartment_id and f.id == ^file_id)
    |> join(:inner, [uc, f], old in Integrity, on: old.id == f.integrity_id)
    |> join(:inner, [uc, f, old], new in Integrity, on: new.name == ^integrity_name)
    |> join(:inner, [uc, f, old, new], uin in Integrity, on: uin.id == uc.integrity_id)
    |> where([uc, f, old, new, uin],
      (new.level > old.level and uin.level >= new.level) or
      (new.level < old.level)
    )
    |> select([uc, f, old, new, uin], uc.id)
    |> Repo.exists?()
  end

  def list_integrities do
    Integrity
    |> order_by([i], i.level)
    |> Repo.all()
  end

  def get_integrity_by_name!(name) do
    Integrity
    |> where([i], i.name == ^name)
    |> Repo.one!()
  end

  def create_integrity(attrs \\ %{}) do
    %Integrity{}
    |> Integrity.changeset(attrs)
    |> Repo.insert()
  end

  def create_compartment_conflict(attrs \\ %{}) do
    %CompartmentConflict{}
    |> CompartmentConflict.changeset(attrs)
    |> Repo.insert()
    |> Repo.preload_after_mutation(CompartmentConflict.preloads())
  end

  def is_user_compartment_in_conflict?(username, compartment_id) do
    CompartmentConflict
    |> where([cc], cc.compartment_a_id == ^compartment_id or cc.compartment_b_id == ^compartment_id)
    |> join(:inner, [cc], uc in UserCompartment, on: uc.username == ^username)
    |> Repo.exists?()
  end
end
