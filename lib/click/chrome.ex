defmodule Click.Chrome do
  alias ChromeRemoteInterface.RPC
  alias Click.Extra
  alias Click.Node

  def describe_node(%Node{id: id, pid: pid}, depth) do
    with {:ok, %{"result" => %{"node" => description}}} <- RPC.DOM.describeNode(pid, %{"nodeId" => id, "depth" => depth}) do
      description
    end
  end

  def get_attributes(%Node{id: id, pid: pid}) do
    with {:ok, %{"result" => %{"attributes" => attributes}}} <- RPC.DOM.getAttributes(pid, %{"nodeId" => id}) do
      Extra.List.to_map(attributes)
    end
  end

  def get_outer_html(%Node{id: id, pid: pid}) do
    with {:ok, %{"result" => %{"outerHTML" => outer_html}}} <- RPC.DOM.getOuterHTML(pid, %{"nodeId" => id}) do
      outer_html
    end
  end

  def query_selector_all(%Node{id: id, pid: pid} = node, query) do
    with {:ok, %{"result" => %{"nodeIds" => node_ids}}} <- RPC.DOM.querySelectorAll(pid, %{"nodeId" => id, "selector" => query}) do
      node_ids |> Enum.map(fn node_id -> %{node | id: node_id} end)
    end
  end
end
