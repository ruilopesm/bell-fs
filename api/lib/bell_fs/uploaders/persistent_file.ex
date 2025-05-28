defmodule BellFS.Uploaders.PersistentFile do
  @moduledoc """
  Waffle module to represent a persistent file.
  """
  use Waffle.Definition
  use Waffle.Ecto.Definition

  alias BellFS.Repo
  alias BellFS.Security.Compartment
  alias BellFS.Structure.File

  def validate({_, _}), do: true

  def filename(_version, {file, _scope}) do
    Path.basename(file.file_name, Path.extname(file.file_name))
  end

  def storage_dir(_version, {file, %File{} = file}) do
    file = Repo.preload(file, :compartment)
    compartment = %Compartment{} = file.compartment

    "uploads/compartments/#{compartment.id}"
  end
end
