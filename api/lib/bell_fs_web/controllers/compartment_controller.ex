defmodule BellFSWeb.CompartmentController do
  use BellFSWeb, :controller

  alias BellFS.Security
  alias BellFS.Security.{Compartment, UserCompartment}

  def create(conn, %{"compartment" => params}) do
    with {:ok, %Compartment{} = compartment} <- Security.create_compartment(params) do
      conn
      |> put_status(:created)
      |> render(:show, compartment: compartment)
    end
  end

  def add_user(conn, %{"id" => id, "username" => username, "user" => params}) do
    params = Map.put(params, "username", username)
    params = Map.put(params, "compartment_id", id)

    confidentiality = Security.get_confidentiality_by_name!(params["confidentiality"])
    params = Map.put(params, "confidentiality_id", confidentiality.id)

    integrity = Security.get_integrity_by_name!(params["integrity"])
    params = Map.put(params, "integrity_id", integrity.id)

    with {:ok, %UserCompartment{} = user_compartment} <- Security.add_user_to_compartment(params) do
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
end
