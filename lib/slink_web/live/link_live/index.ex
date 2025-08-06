defmodule SlinkWeb.LinkLive.Index do
  use SlinkWeb, :live_view

  alias Slink.Links
  require Logger

  # configured in router.ex
  # on_mount {SlinkWeb.UserAuth, :mount_current_scope}

  @per_page 20

  @impl true
  def mount(params, _session, socket) do
    if connected?(socket) do
      Links.subscribe_links(socket.assigns.current_scope)
    end

    search_form = to_form(params)

    {:ok,
     socket
     |> assign(:page_title, "Listing Links")
     |> assign(:search_form, search_form)
     |> assign(page: 1, per_page: @per_page)
     |> stream_items(query: params["query"] || "")}
  end

  @impl true
  def handle_event("search", params, socket) do
    search_form = to_form(params)

    socket =
      socket
      |> assign(:search_form, search_form)
      |> stream_items(query: params["query"], page: 1)

    {:noreply, socket}
  end

  def handle_event("next-page", _, socket) do
    query = socket.assigns.search_form.params["query"]
    {:noreply, stream_items(socket, query: query, page: socket.assigns.page + 1)}
  end

  def handle_event("prev-page", %{"_overran" => true}, socket) do
    query = socket.assigns.search_form.params["query"]
    {:noreply, stream_items(socket, query: query, page: 1)}
  end

  def handle_event("prev-page", _, socket) do
    if socket.assigns.page > 1 do
      query = socket.assigns.search_form.params["query"]
      {:noreply, stream_items(socket, query: query, page: socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, id)
    # NOTE: publish delete event handled by handle_info()
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)
    socket = stream_delete(socket, :links, link)
    {:noreply, socket}
  end

  @impl true
  def handle_info({type, %Slink.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    query = socket.assigns.search_form.params["query"]
    socket = stream_items(socket, query: query)
    {:noreply, socket}
  end

  @doc """
  Stream items with pagination
  """
  def stream_items(socket, opts \\ []) do
    %{per_page: per_page, page: cur_page} = socket.assigns
    query = Keyword.get(opts, :query, "")
    new_page = Keyword.get(opts, :page, 1) |> get_page()

    total_count = Links.search_links_count(query)

    items = Links.search_links(query, page: new_page, per_page: per_page)

    socket =
      socket
      |> assign(:links_count, total_count)

    {items, at, limit} =
      if new_page >= cur_page do
        {items, -1, per_page * 3 * -1}
      else
        {Enum.reverse(items), 0, per_page * 3}
      end

    case items do
      [] ->
        socket
        |> assign(end_of_timeline?: at == -1)
        |> stream(:links, [])

      [_ | _] = items ->
        socket
        |> assign(end_of_timeline?: false)
        |> assign(:page, new_page)
        |> stream(:links, items, at: at, limit: limit, reset: true)
    end
  end

  def get_page(nil), do: 1
  def get_page(page) when is_integer(page) and page >= 1, do: page
  def get_page(page) when is_binary(page), do: page |> String.to_integer() |> get_page()

  # @impl true
  # def render(assigns) do
  #   ~H"""
  #   <Layouts.app flash={@flash} current_scope={@current_scope}>
  #     <.form for={@search_form} phx-change="search">
  #       <.input
  #         type="search"
  #         field={@search_form[:query]}
  #         placeholder="Search title or url..."
  #         phx-debounce="350"
  #         class="w-full input"
  #         autofocus
  #       />
  #     </.form>

  #     <.header>
  #       Links({@links_count})
  #       <:actions>
  #         <.button :if={@current_scope} variant="primary" navigate={~p"/links/new"}>
  #           <.icon name="hero-plus" /> New Link
  #         </.button>
  #       </:actions>
  #     </.header>

  #     <.table
  #       id="links"
  #       rows={@streams.links}
  #       row_click={fn {_id, link} -> JS.navigate(~p"/links/#{link}") end}
  #     >
  #       <:col :let={{_id, link}} label="#">{link.list_index}</:col>
  #       <:col :let={{_id, link}} label="ID">{link.id}</:col>
  #       <:col :let={{_id, link}} label="Title">{link.title}</:col>
  #       <:col :let={{_id, link}} label="Url">
  #         <.link href={link.url} target="_blank">{link.url}</.link>
  #       </:col>
  #       <:col :let={{_id, link}} label="Updated At">{link.updated_at}</:col>
  #       <:col :let={{_id, link}} label="User">{link.user_id}</:col>
  #       <:action :let={{_id, link}} :if={@current_scope}>
  #         <div class="sr-only">
  #           <.link navigate={~p"/links/#{link}"}>Show</.link>
  #         </div>
  #         <.link :if={@current_scope.user.id == link.user_id} navigate={~p"/links/#{link}/edit"}>
  #           Edit
  #         </.link>
  #       </:action>
  #       <:action :let={{id, link}} :if={@current_scope}>
  #         <.link
  #           :if={@current_scope.user.id == link.user_id}
  #           phx-click={JS.push("delete", value: %{id: link.id}) |> hide("##{id}")}
  #           data-confirm="Are you sure?"
  #         >
  #           Delete
  #         </.link>
  #       </:action>
  #     </.table>
  #   </Layouts.app>
  #   """
  # end
end
