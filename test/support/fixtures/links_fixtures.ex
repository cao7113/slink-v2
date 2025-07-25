defmodule Slink.LinksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Slink.Links` context.
  """

  @doc """
  Generate a unique link url.
  """
  def unique_link_url, do: "some url#{System.unique_integer([:positive])}"

  @doc """
  Generate a link.
  """
  def link_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        title: "some title",
        url: unique_link_url()
      })

    {:ok, link} = Slink.Links.create_link(scope, attrs)
    link
  end
end
