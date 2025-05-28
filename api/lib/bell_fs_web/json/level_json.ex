defmodule BellFSWeb.LevelJSON do
  @moduledoc false

  alias BellFS.Security.{Confidentiality, Integrity}

  def index(%{confidentialities: confidentialities, integrities: integrities}) do
    %{
      confidentialities: for(confidentiality <- confidentialities, do: data(confidentiality)),
      integrities: for(integrity <- integrities, do: data(integrity))
    }
  end

  def show(%{confidentiality: confidentiality}) do
    %{confidentiality: data(confidentiality)}
  end

def show(%{integrity: integrity}) do
    %{integrity: data(integrity)}
  end

  def data(%Confidentiality{} = confidentiality) do
    %{
      name: confidentiality.name,
      level: confidentiality.level
    }
  end

  def data(%Integrity{} = integrity) do
    %{
      name: integrity.name,
      level: integrity.level
    }
  end
end
