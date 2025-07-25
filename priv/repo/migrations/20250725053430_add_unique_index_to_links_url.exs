defmodule Slink.Repo.Migrations.AddUniqueIndexToLinksUrl do
  use Ecto.Migration

  def change do
    create unique_index(:links, [:url])
  end
end
