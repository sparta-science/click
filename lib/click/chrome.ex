defmodule Click.Chrome do
  alias ChromeRemoteInterface.RPC
  alias Click.Browser
  alias Click.Extra
  alias Click.DomNode

  def call_function_on({%Browser{pid: pid}, %DomNode{id: id}}, javascript) do
    with {:ok, %{"result" => %{"object" => %{"objectId" => object_id}}}} <- RPC.DOM.resolveNode(pid, %{"nodeId" => id}),
         {:ok, %{"result" => %{"result" => result}}} <- RPC.Runtime.callFunctionOn(pid, %{"functionDeclaration" => "function() { #{javascript} }", "objectId" => object_id}) do
      case result do
        %{"type" => "string", "value" => value} -> {:ok, value}
        %{"type" => "undefined"} -> {:ok, "undefined"}
      end
    end
  end

  def capture_screenshot({%Browser{pid: pid}, _node}) do
    with {:ok, %{"result" => %{"data" => data}}} <- RPC.Page.captureScreenshot(pid, %{}) do
      {:ok, data}
    end
  end

  def describe_node({%Browser{pid: pid}, %DomNode{id: id}}, depth) do
    with {:ok, %{"result" => %{"node" => description}}} <- RPC.DOM.describeNode(pid, %{"nodeId" => id, "depth" => depth}) do
      {:ok, description}
    end
  end

  def dispatch_key_event({%Browser{pid: pid}, _node}, event_type, code, key_code, key, text) do
    with {:ok, %{"result" => %{}}} <- RPC.Input.dispatchKeyEvent(pid, %{"type" => event_type, "keyCode" => key_code, "code" => code, "key" => key, "text" => text}) do
      :ok
    end
  end

  def dispatch_mouse_event({%Browser{pid: pid}, _node}, event_type, x, y, button) do
    with {:ok, %{"result" => %{}}} <- RPC.Input.dispatchMouseEvent(pid, %{"type" => event_type, "x" => x, "y" => y, "button" => button, "clickCount" => 1}) do
      :ok
    end
  end

  def evaluate(%Browser{pid: pid}, javascript) do
    with {:ok, %{"result" => %{"result" => result}}} <- RPC.Runtime.evaluate(pid, %{"expression" => javascript}) do
      case result do
        %{"type" => "string", "value" => value} -> {:ok, value}
        %{"type" => "undefined"} -> {:ok, "undefined"}
      end
    end
  end

  def focus({%Browser{pid: pid}, %DomNode{id: id}}) do
    with {:ok, %{"result" => %{}}} <- RPC.DOM.focus(pid, %{"nodeId" => id}) do
      :ok
    end
  end

  def get_attributes({%Browser{pid: pid}, %DomNode{id: id}}) do
    with {:ok, %{"result" => %{"attributes" => attributes}}} <- RPC.DOM.getAttributes(pid, %{"nodeId" => id}) do
      {:ok, Extra.List.to_map(attributes)}
    end
  end

  def get_attributes({%Browser{}, %DomNode{}} = context, attribute_name) do
    with {:ok, attribute_map} <- get_attributes(context) do
      {:ok, Map.get(attribute_map, attribute_name)}
    end
  end

  def get_box_model({%Browser{pid: pid}, %DomNode{id: id}}) do
    with {:ok, %{"result" => %{"model" => %{"content" => content}}}} <- RPC.DOM.getBoxModel(pid, %{"nodeId" => id}) do
      {:ok, content}
    end
  end

  def get_document(%Browser{pid: pid}) do
    with {:ok, %{"result" => %{"root" => %{"nodeId" => id}}}} <- RPC.DOM.getDocument(pid) do
      {:ok, DomNode.new(id)}
    end
  end

  def get_outer_html({%Browser{pid: pid}, %DomNode{id: id}}) do
    with {:ok, %{"result" => %{"outerHTML" => outer_html}}} <- RPC.DOM.getOuterHTML(pid, %{"nodeId" => id}) do
      {:ok, outer_html}
    end
  end

  def get_user_agent({%Browser{pid: pid}, _node}) do
    with {:ok, %{"result" => %{"userAgent" => user_agent}}} <- RPC.Browser.getVersion(pid) do
      {:ok, user_agent}
    end
  end

  def navigate(%Browser{pid: pid, base_url: base_url}, path) do
    with {:ok, _} <- RPC.Page.enable(pid),
         {:ok, _} <- RPC.Page.navigate(pid, %{url: URI.merge(base_url, path) |> to_string()}) do
      :ok
    end
  end

  def print_to_pdf({%Browser{pid: pid}, _node}) do
    with {:ok, %{"result" => %{"data" => data}}} <- RPC.Page.printToPDF(pid, %{}) do
      {:ok, data}
    end
  end

  def query_selector({%Browser{pid: pid}, %DomNode{id: id}}, query) do
    with {:ok, %{"result" => %{"nodeId" => node_id}}} <- RPC.DOM.querySelector(pid, %{"nodeId" => id, "selector" => query}) do
      {:ok, DomNode.new(node_id)}
    end
  end

  def query_selector_all({%Browser{pid: pid}, %DomNode{id: id}}, query) do
    with {:ok, %{"result" => %{"nodeIds" => node_ids}}} <- RPC.DOM.querySelectorAll(pid, %{"nodeId" => id, "selector" => query}) do
      {:ok, node_ids |> Enum.map(&DomNode.new/1)}
    end
  end

  def set_attribute({%Browser{pid: pid}, %DomNode{id: id}}, attr, value) do
    with {:ok, %{"result" => %{}}} <- RPC.DOM.setAttributeValue(pid, %{"nodeId" => id, "name" => attr, "value" => value}) do
      :ok
    end
  end

  def set_user_agent(%Browser{pid: pid}, user_agent) do
    with {:ok, _} <- RPC.Network.setUserAgentOverride(pid, %{"userAgent" => user_agent}) do
      :ok
    end
  end
end
