defmodule Click.Chrome do
  alias ChromeRemoteInterface.RPC
  alias Click.Extra
  alias Click.DomNode
  alias Click.Quad

  def describe_node(%DomNode{id: id, pid: pid}, depth) do
    with {:ok, %{"result" => %{"node" => description}}} <- RPC.DOM.describeNode(pid, %{"nodeId" => id, "depth" => depth}) do
      description
    end
  end

  def dispatch_mouse_event(%DomNode{id: id, pid: pid}, event, x, y, button) do
    with {:ok, %{"result" => %{}}} <- RPC.Input.dispatchMouseEvent(pid, %{"type" => event, "x" => x, "y" => y, "button" => button, "clickCount" => 1}) do
      :ok
    end
  end

  def get_attributes(%DomNode{id: id, pid: pid}) do
    with {:ok, %{"result" => %{"attributes" => attributes}}} <- RPC.DOM.getAttributes(pid, %{"nodeId" => id}) do
      Extra.List.to_map(attributes)
    end
  end

  def get_box_model(%DomNode{id: id, pid: pid}) do
    with {:ok, %{"result" => %{"model" => %{"content" => content}}}} <- RPC.DOM.getBoxModel(pid, %{"nodeId" => id}) do
      content
    end
  end

  def get_outer_html(%DomNode{id: id, pid: pid}) do
    with {:ok, %{"result" => %{"outerHTML" => outer_html}}} <- RPC.DOM.getOuterHTML(pid, %{"nodeId" => id}) do
      outer_html
    end
  end

  def query_selector_all(%DomNode{id: id, pid: pid} = node, query) do
    with {:ok, %{"result" => %{"nodeIds" => node_ids}}} <- RPC.DOM.querySelectorAll(pid, %{"nodeId" => id, "selector" => query}) do
      node_ids |> Enum.map(fn node_id -> %{node | id: node_id} end)
    end
  end
end
