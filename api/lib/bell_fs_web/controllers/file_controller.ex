defmodule BellFSWeb.FileController do
  use BellFSWeb, :controller

  alias BellFS.Structure
  alias BellFS.Structure.File

  def index(conn, _params) do
    current_user = conn.assigns.current_user
    files = Structure.list_files(current_user)

    conn
    |> put_status(:ok)
    |> render(:index, files: files)
  end

  def create(conn, %{"file" => params}) do
    current_user = conn.assigns.current_user

    attrs = %{
      "compartment_id" => params["compartment_id"],
      "confidentiality_id" => params["confidentiality_id"],
      "integrity_id" => params["integrity_id"]
    }

    if Structure.can_create_file?(current_user, attrs) do
      with {:ok, %File{} = file} <- Structure.create_file(params) do
        conn
        |> put_status(:created)
        |> render(:show, file: file)
      end
    else
      forbidden(conn)
    end
  end

  defp forbidden(conn) do
    conn
    |> put_status(:forbidden)
    |> put_view(BellFSWeb.ErrorJSON)
    |> render(:"403")
  end
end
