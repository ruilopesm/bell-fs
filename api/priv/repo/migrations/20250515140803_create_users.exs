defmodule BellFS.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :username, :string, primary_key: true

      add :certificate, :text, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
