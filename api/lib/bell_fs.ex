defmodule BellFS do
  @moduledoc """
  BellFS keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def context do
    quote do
      import Ecto.Query, warn: false
      import Ecto.Query.API

      alias Ecto.Changeset
      alias Ecto.Multi
      alias BellFS.Repo
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      use Waffle.Ecto.Schema

      import Ecto.Changeset
    end
  end

  @doc """
  When used, dispatch to the appropriate schema/context/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
