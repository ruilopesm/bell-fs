defmodule BellFS.Security do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Security.{
    Compartment,
    CompartmentConflict,
    Confidentiality,
    Integrity,
    UserCompartment
  }

  ### Compartments

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

  def has_access_to_compartment?(username, compartment_id) do
    UserCompartment
    |> where([uc], uc.username == ^username and uc.compartment_id == ^compartment_id)
    |> Repo.exists?()
  end

  def add_user_to_compartment(attrs \\ %{}) do
    %UserCompartment{}
    |> UserCompartment.changeset(attrs)
    |> Repo.insert()
    |> Repo.after_insert_preload(UserCompartment.preloads())
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
  end
end
