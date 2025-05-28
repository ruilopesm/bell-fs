defmodule BellFSWeb.FileJSON do
  @moduledoc false

  alias BellFS.Security.{Confidentiality, Integrity}
  alias BellFS.Structure.File
  alias BellFSWeb.LevelJSON

  def index(%{files: files}) do
    %{files: for(file <- files, do: lazy(file))}
  end

  def show(%{file: %File{} = file}) do
    %{file: data(file)}
  end

  def read(%{file: %File{} = file}) do
    data = data(file) |> Map.drop([:confidentiality, :integrity])
    %{file: data}
  end

  def data(%File{} = file) do
    confidentiality = %Confidentiality{} = file.confidentiality
    integrity = %Integrity{} = file.integrity

    %{
      id: file.id,
      name: file.name,
      content: file.content,
      confidentiality: LevelJSON.data(confidentiality),
      integrity: LevelJSON.data(integrity)
    }
  end

  def lazy(%File{} = file) do
    %{
      id: file.id,
      name: file.name,
      confidentiality: LevelJSON.data(file.confidentiality),
      integrity: LevelJSON.data(file.integrity)
    }
  end
end
