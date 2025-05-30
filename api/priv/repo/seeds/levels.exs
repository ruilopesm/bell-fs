defmodule BellFS.Repo.Seeds.Levels do
  @moduledoc false

  alias BellFS.Security
  alias BellFS.Security.Confidentiality
  alias BellFS.Repo

  @confidentialities [
    "Unclassified",
    "Classified",
    "Secret",
    "Top Secret"
  ]

  @integrities [
    "Weak",
    "Medium",
    "Strong"
  ]

  def run do
    case Repo.all(Confidentiality) do
      [] ->
        seed_confidentialities()
        seed_integrities()

      _  ->
        Mix.shell().error("Found levels, aborting seeding levels.")
    end
  end

  def seed_confidentialities do
    @confidentialities
    |> Enum.with_index(1)
    |> Enum.each(fn {name, index} ->
      %{
        "name" => name,
        "level" => index
      }
      |> Security.create_confidentiality()
    end)
  end

  def seed_integrities do
    @integrities
    |> Enum.with_index(1)
    |> Enum.each(fn {name, index} ->
      %{
        "name" => name,
        "level" => index
      }
      |> Security.create_integrity()
    end)
  end
end

BellFS.Repo.Seeds.Levels.run()
