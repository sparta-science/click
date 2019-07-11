defmodule Click.Chrome do
  alias ChromeRemoteInterface.RPC
  alias Click.Extra
  alias Click.DomNode

  def capture_screenshot(%DomNode{pid: pid}) do
    with {:ok, %{"result" => %{"data" => data}}} <- RPC.Page.captureScreenshot(pid, %{}) do
      data
    end
  end

  def click(%DomNode{id: id, pid: pid} = node) do
    with {:ok, %{"result" => %{"object" => %{"objectId" => object_id}}}} <- RPC.DOM.resolveNode(pid, %{"nodeId" => id}),
         {:ok, _} <- RPC.Runtime.callFunctionOn(pid, %{"functionDeclaration" => "function() { this.click(); }", "objectId" => object_id}) do
      node
    end
  end

  def describe_node(%DomNode{id: id, pid: pid}, depth) do
    with {:ok, %{"result" => %{"node" => description}}} <- RPC.DOM.describeNode(pid, %{"nodeId" => id, "depth" => depth}) do
      description
    end
  end

  def dispatch_key_event(%DomNode{pid: pid} = node, event_type, code, key_code, key, text) do
    with {:ok, %{"result" => %{}}} <- RPC.Input.dispatchKeyEvent(pid, %{"type" => event_type, "keyCode" => key_code, "code" => code, "key" => key, "text" => text}) do
      node
    end
  end

  def dispatch_mouse_event(%DomNode{pid: pid} = node, event_type, x, y, button) do
    with {:ok, %{"result" => %{}}} <- RPC.Input.dispatchMouseEvent(pid, %{"type" => event_type, "x" => x, "y" => y, "button" => button, "clickCount" => 1}) do
      node
    end
  end

  def focus(%DomNode{id: id, pid: pid} = node) do
    with {:ok, %{"result" => %{}}} <- RPC.DOM.focus(pid, %{"nodeId" => id}) do
      node
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

  def navigate(%DomNode{base_url: base_url, pid: pid} = node, path) do
    with {:ok, _} <- RPC.Page.enable(pid),
         {:ok, _} <- RPC.Page.navigate(pid, %{url: URI.merge(base_url, path) |> to_string()}) do
      node
    end
  end

  def query_selector_all(%DomNode{id: id, pid: pid} = node, query) do
    with {:ok, %{"result" => %{"nodeIds" => node_ids}}} <- RPC.DOM.querySelectorAll(pid, %{"nodeId" => id, "selector" => query}) do
      node_ids |> Enum.map(fn node_id -> %{node | id: node_id} end)
    end
  end

  def scroll_into_view(%DomNode{id: id, pid: pid} = node) do
    with {:ok, %{"result" => %{"object" => %{"objectId" => object_id}}}} <- RPC.DOM.resolveNode(pid, %{"nodeId" => id}),
         {:ok, _} <- RPC.Runtime.callFunctionOn(pid, %{"functionDeclaration" => "function() { this.scrollIntoView(); }", "objectId" => object_id}) do
      node
    end
  end

  def set_attribute(%DomNode{id: id, pid: pid} = node, attr, value) do
    with {:ok, %{"result" => %{}}} <- RPC.DOM.setAttributeValue(pid, %{"nodeId" => id, "name" => attr, "value" => value}) do
      node
    end
  end
end
