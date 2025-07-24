defmodule SlinkWeb.LinkLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Links
  require Logger

  on_mount {SlinkWeb.UserAuth, :mount_current_scope}

  @impl true
  def render(assigns) do
    Logger.debug("rendering index page")

    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Links
        <:actions>
          <.button :if={@current_scope} variant="primary" navigate={~p"/links/new"}>
            <.icon name="hero-plus" /> New Link
          </.button>
        </:actions>
      </.header>

      <.table
        id="links"
        rows={@streams.links}
        row_click={fn {_id, link} -> JS.navigate(~p"/links/#{link}") end}
      >
        <:col :let={{_id, link}} label="ID">{link.id}</:col>
        <:col :let={{_id, link}} label="Title">{link.title}</:col>
        <:col :let={{_id, link}} label="Url">{link.url}</:col>
        <:col :let={{_id, link}} label="User">{link.user_id}</:col>
        <:col :let={{_id, link}} label="Updated At">{link.updated_at}</:col>
        <:action :let={{_id, link}} :if={@current_scope}>
          <div class="sr-only">
            <.link navigate={~p"/links/#{link}"}>Show</.link>
          </div>
          <.link :if={@current_scope.user.id == link.user_id} navigate={~p"/links/#{link}/edit"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, link}} :if={@current_scope}>
          <.link
            :if={@current_scope.user.id == link.user_id}
            phx-click={JS.push("delete", value: %{id: link.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("mounting index page")

    if connected?(socket) do
      Links.subscribe_links(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Links")
     |> stream(:links, Links.list_links(nil))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    Logger.debug("delete event on index page")
    link = Links.get_link!(socket.assigns.current_scope, id)
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)

    {:noreply, stream_delete(socket, :links, link)}
  end

  @impl true
  def handle_info({type, %Slink.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    Logger.debug("handle_info index page")

    {:noreply,
     stream(socket, :links, Links.list_links(socket.assigns.current_scope), reset: true)}
  end
end
