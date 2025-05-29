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

  def index(%{compartments: compartments}) do
    %{compartments: for(compartment <- compartments, do: full(compartment))}
  end

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
    compartment = %Compartment{} = user_compartment.compartment
    confidentiality = %Confidentiality{} = user_compartment.confidentiality
    integrity = %Integrity{} = user_compartment.integrity

    %{
      id: user_compartment.id,
      username: user_compartment.username,
      trusted: user_compartment.trusted,
      compartment: data(compartment),
      confidentiality: LevelJSON.data(confidentiality),
      integrity: LevelJSON.data(integrity)
    }
  end

  def data(%CompartmentConflict{} = compartment_conflict) do
    compartment_a = %Compartment{} = compartment_conflict.compartment_a
    compartment_b = %Compartment{} = compartment_conflict.compartment_b

    %{
      compartment_a: data(compartment_a),
      compartment_b: data(compartment_b)
    }
  end

  def full(%{compartment: compartment, uc: user_compartment}) do
    confidentiality = %Confidentiality{} = user_compartment.confidentiality
    integrity = %Integrity{} = user_compartment.integrity

    %{
      trusted: user_compartment.trusted,
      confidentiality: LevelJSON.data(confidentiality),
      integrity: LevelJSON.data(integrity),
    }
    |> Map.merge(data(compartment))
  end
end
