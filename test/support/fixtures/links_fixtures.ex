defmodule Slink.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Links` context.
  """

  @doc """
  Generate a link.
  """
  def link_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "some title",
        url: "some url"
      })

    {:ok, link} = Slink.Links.create_link(scope, attrs)
    link
  end
end
