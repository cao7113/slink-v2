defmodule Slink.Repo.Migrations.AddIndexToLinksTitle do
  use Ecto.Migration

  def change do
    create index(:links, [:title])
  end
end
