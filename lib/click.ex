defmodule Click do
  alias Click.Browser
  alias Click.Chrome
  alias Click.Node

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

  def html(nodes) do
    nodes |> List.wrap() |> Enum.map(&Chrome.get_outer_html(&1))
  end

  def navigate(%Node{} = node, path) do
    with {:ok, node} <- Browser.navigate(node, path),
         {:ok, node} <- Browser.get_document(node) do
      node
    end
  end

  def text(nodes) do
    nodes
    |> List.wrap()
    |> Enum.map(&Chrome.describe_node(&1, -1))
    |> Enum.map(& &1["children"])
    |> List.flatten()
    |> Enum.filter(&(&1["nodeName"] == "#text"))
    |> Enum.map(& &1["nodeValue"])
  end

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"

  #  defp retry(fun, count \\ 10) do
  #    case fun.() do
  #      {:ok, result} ->
  #        {:ok, result}
  #
  #      result ->
  #        if count == 0,
  #          do: result,
  #          else: :timer.sleep(100) && IO.write("®") && retry(fun, count - 1)
  #    end
  #  end
end
