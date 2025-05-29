defmodule BellFSWeb.CompartmentController do
  use BellFSWeb, :controller

  alias BellFS.Security.CompartmentConflict
  alias BellFS.Security
  alias BellFS.Security.{Compartment, UserCompartment}

  def list(conn, _) do
    user = conn.assigns.current_user
    compartments = Security.list_compartments(user)
    conn
    |> put_status(:ok)
    |> render(:show, compartments: compartments)
  end

  def create(conn, %{"compartment" => params}) do
    with {:ok, %Compartment{} = compartment} <- Security.create_compartment(params) do
      conn
      |> put_status(:created)
      |> render(:show, compartment: compartment)
    end
  end

  def add_user(conn, %{"id" => id, "username" => username, "user" => params}) do
    attrs = %{}

    attrs = Map.put(attrs, "username", username)
    attrs = Map.put(attrs, "compartment_id", id)

    confidentiality = Security.get_confidentiality_by_name!(params["confidentiality"])
    attrs = Map.put(attrs, "confidentiality_id", confidentiality.id)

    integrity = Security.get_integrity_by_name!(params["integrity"])
    attrs = Map.put(attrs, "integrity_id", integrity.id)

    with {:ok, %UserCompartment{} = user_compartment} <- Security.add_user_to_compartment(attrs) do
      conn
      |> put_status(:created)
      |> render(:show, user_compartment: user_compartment)
    end
  end

  def remove_user(conn, %{"id" => id, "username" => username}) do
    with {:ok, %UserCompartment{} = _deleted} <- Security.remove_user_from_compartment(id, username) do
      send_resp(conn, :no_content, "")
    end
  end

  def add_conflict(conn, %{"conflict" => params}) do

    compartment_a = Security.get_compartment_by_name!(params["compartment_a_name"])
    compartment_b = Security.get_compartment_by_name!(params["compartment_b_name"])
    with {:ok, %CompartmentConflict{} = conflict} <- Security.create_compartment_conflict(%{compartment_a_id: compartment_a.id, compartment_b_id: compartment_b.id}) do
      conn
      |> put_status(:created)
      |> render(:show, compartment_conflict: conflict)
    end
  end
end
