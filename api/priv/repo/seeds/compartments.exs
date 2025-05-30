defmodule BellFS.Repo.Seeds.Compartments do
  @moduledoc false

  alias BellFS.Security
  alias BellFS.Security.Compartment
  alias BellFS.Repo

  @compartments [
    "Porto",
    "Braga",
    "Lisboa"
  ]

  def run do
    case Repo.all(Compartment) do
      [] ->
        seed_compartments()

      _  ->
        Mix.shell().error("Found compartments, aborting seeding compartments.")
    end
  end

  def seed_compartments do
    @compartments
    |> Enum.each(fn name ->
      %{
        "name" => name
      }
      |> Security.create_compartment()
    end)
  end
end

BellFS.Repo.Seeds.Compartments.run()
