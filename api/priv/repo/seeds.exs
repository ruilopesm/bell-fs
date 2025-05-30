defmodule BellFS.Repo.Seeds do
  @moduledoc false

  @seeds_dir "priv/repo/seeds"

  def run do
    [
      "levels.exs",
      "compartments.exs"
    ]
    |> Enum.each(fn file ->
      Code.require_file("#{@seeds_dir}/#{file}")
    end)
  end
end

BellFS.Repo.Seeds.run()
