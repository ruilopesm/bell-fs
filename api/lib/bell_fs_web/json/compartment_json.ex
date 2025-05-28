defmodule BellFSWeb.CompartmentJSON do
  @moduledoc false

  alias BellFS.Security.{
    Compartment,
    CompartmentConflict,
    Confidentiality,
    Integrity,
    UserCompartment
  }
  alias BellFSWeb.LevelJSON

  def show(%{compartment: compartment}) do
    %{compartment: data(compartment)}
  end

  def show(%{user_compartment: user_compartment}) do
    %{user_compartment: data(user_compartment)}
  end

  def show(%{compartment_conflict: compartment_conflict}) do
    %{compartment_conflict: data(compartment_conflict)}
  end

  def data(%Compartment{} = compartment) do
    %{
      id: compartment.id,
      name: compartment.name
    }
  end

  def data(%UserCompartment{} = user_compartment) do
    confidentiality = %Confidentiality{} = user_compartment.confidentiality
    integrity = %Integrity{} = user_compartment.integrity

    %{
      id: user_compartment.id,
      username: user_compartment.username,
      compartment_id: user_compartment.compartment_id,
      trusted: user_compartment.trusted,
      confidentiality: LevelJSON.data(confidentiality),
      integrity: LevelJSON.data(integrity),
    }
  end

  def data(%CompartmentConflict{} = compartment_conflict) do
    %{
      id: compartment_conflict.id,
      compartment_a_id: compartment_conflict.compartment_a_id,
      compartment_b_id: compartment_conflict.compartment_b_id
    }
  end
end
