defmodule Click.Chrome do
  alias ChromeRemoteInterface.RPC
  alias Click.Extra

  def describe_node(pid, nodes, depth) when is_list(nodes),
    do: with_nodes(nodes, &describe_node(pid, &1, depth))

  def describe_node(pid, node, depth) do
    with {:ok, %{"result" => %{"node" => description}}} <- RPC.DOM.describeNode(pid, %{"nodeId" => node, "depth" => depth}) do
      description
    end
  end

  def get_attributes(pid, nodes) when is_list(nodes),
    do: with_nodes(nodes, &get_attributes(pid, &1))

  def get_attributes(pid, node) do
    with {:ok, %{"result" => %{"attributes" => attributes}}} <- RPC.DOM.getAttributes(pid, %{"nodeId" => node}) do
      Extra.List.to_map(attributes)
    end
  end

  def get_outer_html(pid, nodes) when is_list(nodes),
    do: with_nodes(nodes, &get_outer_html(pid, &1))

  def get_outer_html(pid, node) do
    with {:ok, %{"result" => %{"outerHTML" => outer_html}}} <- RPC.DOM.getOuterHTML(pid, %{"nodeId" => node}) do
      outer_html
    end
  end

  def query_selector_all(pid, nodes, query) when is_list(nodes),
    do: with_nodes(nodes, &query_selector_all(pid, &1, query))

  def query_selector_all(pid, node, query) do
    with {:ok, %{"result" => %{"nodeIds" => nodes}}} <- RPC.DOM.querySelectorAll(pid, %{"nodeId" => node, "selector" => query}) do
      nodes
    end
  end

  defp with_nodes(nodes, fun),
    do: nodes |> Enum.map(fun) |> List.flatten()
end
