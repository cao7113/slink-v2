defmodule Remote do
  @moduledoc """
  Remote ops within a cluster

  Node info https://hexdocs.pm/elixir/1.18.4/Node.html#spawn/2
  erpc https://www.erlang.org/doc/apps/kernel/erpc.html
  """
  require Logger

  @doc """
  Get node info
  """
  def info() do
    %{
      node: node(),
      alive: Node.alive?(),
      cookie: Node.get_cookie(),
      list: Node.list(),
      connected: Node.list(:connected),
      hidden: Node.list(:hidden)
    }
  end

  @doc """
  Test rpc call with remote node
  """
  def rpc_test(node \\ first_remote_node() || node()) do
    :erpc.call(node, Node, :self, [])
  end

  @doc """
  Find first remote node begin with prefix

  ## Examples
    [:"slink-01K0ZHJ4MVRWSR4GMDY5S4VMK4@fdaa:2:686c:a7b:fc:cf02:d919:2"]
    -> :"slink-01K0ZHJ4MVRWSR4GMDY5S4VMK4@fdaa:2:686c:a7b:fc:cf02:d919:2"
  """
  def first_remote_node(prefix \\ "slink") do
    :connected
    |> Node.list()
    |> Enum.find(fn atom_name ->
      String.starts_with?(atom_name |> to_string(), prefix)
    end)
  end

  def add_new_node(node, cookie \\ Node.get_cookie()) when is_atom(node) and is_atom(cookie) do
    Node.set_cookie(cookie)
    Node.connect(node)
    # Node.list(:connected)
  end

  ## Links

  def fetch_remote_links(node \\ first_remote_node()) do
    :erpc.call(node, Slink.Links.Link, :all, [])
  end

  def download_remote_links!(node \\ first_remote_node()) do
    node
    |> fetch_remote_links()
    |> Enum.with_index(fn link, idx ->
      Logger.info("downloading [#{idx}] id=#{link.id} #{link.url}")

      Slink.Links.Link.find_by(url: link.url)
      |> case do
        nil ->
          # require user_id match
          new_link = Slink.Links.Link.create!(link)
          Logger.info("created local link #{new_link.id}")

        found ->
          Logger.info("already existed local link: #{found.id} with url: #{link.url}")
      end
    end)
  end

  def upload_remote_links!(node, links) when is_list(links) do
    ignore_struct_fields = [:__meta__, :user]

    links
    |> Enum.with_index(fn link, idx ->
      Logger.info("uploading [#{idx}] id=#{link.id} #{link.url}")

      :erpc.call(node, Slink.Links.Link, :find_by, [[url: link.url]])
      |> case do
        nil ->
          attrs =
            link
            |> Map.from_struct()
            |> Enum.reject(fn {k, _v} ->
              ignore_struct_fields |> Enum.member?(k)
            end)

          # require user_id match
          new_link = :erpc.call(node, Slink.Links.Link, :create!, [attrs])
          Logger.info("created remote link #{new_link.id}")

        found ->
          Logger.info("already existed link: #{found.id} with url: #{link.url}")
      end
    end)
  end
end
