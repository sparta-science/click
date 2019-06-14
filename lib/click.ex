defmodule Click do
  alias Click.Browser
  alias Click.Chrome
  alias Click.DomNode
  alias Click.NodeDescription

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def connect(opts \\ []) do
    Browser.new(
      "http://localhost:4001",
      user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
    )
  end

  def attr(nodes, attr_name) do
    nodes |> List.wrap() |> find_all("[#{attr_name}]") |> Enum.map(&Chrome.get_attributes(&1)) |> Enum.map(& &1[attr_name])
  end

  def find_all(nodes, query) do
    nodes |> List.wrap() |> Enum.flat_map(&Chrome.query_selector_all(&1, query))
  end

  def find_first(nodes, query) do
    nodes |> find_all(query) |> List.first()
  end

  def html(nodes) when is_list(nodes) do
    nodes |> Enum.map(&Chrome.get_outer_html(&1))
  end

  def html(nil), do: nil
  def html(node), do: [node] |> html() |> List.first()

  def navigate(%DomNode{} = node, path) do
    with {:ok, node} <- Browser.navigate(node, path),
         {:ok, node} <- Browser.get_document(node) do
      node
    end
  end

  def text(node_or_nodes, depth \\ -1)

  def text(nodes, depth) when is_list(nodes),
    do: nodes |> Enum.map(&text(&1, depth))

  def text(nil, _depth),
    do: nil

  def text(node, depth) when is_integer(depth),
    do: node |> Chrome.describe_node(depth) |> NodeDescription.extract_text() |> Enum.map(&String.trim/1) |> Enum.join(" ")

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"
end
