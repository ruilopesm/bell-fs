defmodule BellFSWeb.FileJSON do
  @moduledoc false

  alias BellFS.Security.{Confidentiality, Integrity}
  alias BellFS.Structure.File
  alias BellFSWeb.LevelJSON

  def index(%{files: files}) do
    %{files: for(file <- files, do: data(file))}
  end

  def data(%File{} = file) do
    confidentiality = %Confidentiality{} = file.confidentiality
    integrity = %Integrity{} = file.integrity

    %{
      name: file.name,
      confidentiality: LevelJSON.data(confidentiality),
      integrity: LevelJSON.data(integrity)
    }
  end
end
