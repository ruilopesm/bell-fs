defmodule BellFSWeb.LevelController do
  use BellFSWeb, :controller

  alias BellFS.Security
  alias BellFS.Security.{Confidentiality, Integrity}

  def index(conn, _params) do
    confidentialities = Security.list_confidentialities()
    integrities = Security.list_integrities()

    conn
    |> put_status(:ok)
    |> render(:index, confidentialities: confidentialities, integrities: integrities)
  end

  def create_confidentiality(conn, %{"confidentiality" => params}) do
    with {:ok, %Confidentiality{} = confidentiality} <- Security.create_confidentiality(params) do
      conn
      |> put_status(:created)
      |> render(:show, confidentiality: confidentiality)
    end
  end

  def create_integrity(conn, %{"integrity" => params}) do
    with {:ok, %Integrity{} = integrity} <- Security.create_integrity(params) do
      conn
      |> put_status(:created)
      |> render(:show, integrity: integrity)
    end
  end
end
