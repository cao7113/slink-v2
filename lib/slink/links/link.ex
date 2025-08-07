defmodule Slink.Links.Link do
  use Endon
  use Ecto.Schema
  import Ecto.Changeset

  @default_limit 20

  # https://hexdocs.pm/flop/Flop.Schema.html#module-usage
  @derive {
    Flop.Schema,
    max_limit: 200,
    default_limit: @default_limit,
    filterable: [:title, :url],
    sortable: [:id, :updated_at],
    default_order: %{
      order_by: [:id],
      order_directions: [:desc]
    }
  }

  schema "links" do
    field :title, :string
    field :url, :string
    field :user_id, :id
    field :list_index, :integer, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs, user_scope) do
    link
    |> cast(attrs, [:title, :url])
    |> validate_required([:title, :url])
    |> put_change(:user_id, user_scope.user.id)
    |> unique_constraint(:url, name: "links_url_index")
  end

  @doc """
  New changeset allow inserted_at, updated_at builtin attributes
  """
  def new_changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> Ecto.Changeset.change(attrs)
    |> unique_constraint(:url, name: "links_url_index")
  end

  @doc """
  Get new attributes from a link struct.
  """
  def get_new_attrs(%__MODULE__{} = link) do
    link
    |> Map.from_struct()
    # ignore local :id to avoid id-sequence conflict
    |> Map.take([
      :title,
      :url,
      :user_id,
      :inserted_at,
      :updated_at
    ])
  end
end
