defmodule BellFSWeb.FileController do
  use BellFSWeb, :controller

  alias BellFS.Security
  alias BellFS.Structure
  alias BellFS.Structure.File

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    files = Structure.list_files(current_user)

    conn
    |> put_status(:ok)
    |> render(:index, files: files)
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    can_read? = Structure.can_read_file?(current_user, id)

    if can_read? do
      file = Structure.get_file!(id)

      conn
      |> put_status(:ok)
      |> render(:read, file: file)
    else
      forbidden(conn)
    end
  end

  def create(conn, %{"file" => params}) do
    attrs = %{}

    compartment = Security.get_compartment_by_name!(params["compartment"])
    attrs = Map.put(attrs, "compartment_id", compartment.id)

    confidentiality = Security.get_confidentiality_by_name!(params["confidentiality"])
    attrs = Map.put(attrs, "confidentiality_id", confidentiality.id)

    integrity = Security.get_integrity_by_name!(params["integrity"])
    attrs = Map.put(attrs, "integrity_id", integrity.id)

    current_user = conn.assigns.current_user
    can_create? = Structure.can_create_file?(current_user, attrs)

    if can_create? do
      attrs = Map.put(attrs, "name", params["name"])
      attrs = Map.put(attrs, "content", params["content"])

      with {:ok, %File{} = file} <- Structure.create_file(attrs) do
        conn
        |> put_status(:created)
        |> render(:show, file: file)
      end
    else
      forbidden(conn)
    end
  end

  def update(conn, %{"id" => id, "file" => params}) do
    editable_fields = File.editable_fields() |> Enum.map(&Atom.to_string/1)
    params = Map.take(params, editable_fields)

    current_user = conn.assigns.current_user
    can_update? = Structure.can_update_file?(current_user, id)

    if can_update? do
      file = Structure.get_file!(id)

      with {:ok, %File{} = file} <- Structure.update_file(file, params) do
        conn
        |> put_status(:ok)
        |> render(:show, file: file)
      end
    else
      forbidden(conn)
    end
  end
end
