defmodule BellFS.Security do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Security.{
    Compartment,
    Confidentiality,
    Integrity,
    UserCompartment
  }

  ### Compartments

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

  def create_integrity(attrs \\ %{}) do
    %Integrity{}
    |> Integrity.changeset(attrs)
    |> Repo.insert()
  end
end
