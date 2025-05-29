defmodule BellFS.Audit do
  @moduledoc false

  use BellFS, :context

  alias BellFS.Audit.Log

  def create_log(attrs \\ %{}) do
    %Log{}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end
end
