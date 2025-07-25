defmodule Slink.Links.Link do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :title, :string
    field :url, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs, user_scope) do
    link
    |> cast(attrs, [:title, :url])
    |> validate_required([:title, :url])
    |> put_change(:user_id, user_scope.user.id)
    # unique_constraint(:url, name: :links_url_index)
    |> unique_constraint(:url)
  end
end
