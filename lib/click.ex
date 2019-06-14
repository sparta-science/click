defmodule Click do
  alias Click.Browser
  alias Click.Chrome
  alias Click.DomNode

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

  def text(nodes) when is_list(nodes) do
    nodes
    |> Enum.map(&Chrome.describe_node(&1, -1))
    |> Enum.map(& &1["children"])
    |> List.flatten()
    |> Enum.filter(&(&1["nodeName"] == "#text"))
    |> Enum.map(& &1["nodeValue"])
  end

  def text(nil), do: nil
  def text(node), do: [node] |> text() |> List.first()

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
