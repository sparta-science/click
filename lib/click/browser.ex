defmodule Click.Browser do
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC
  alias Click.Chrome
  alias Click.DomNode
  alias Click.Quad

  def new!(base_url, opts \\ []) do
    case new(base_url, opts) do
      {:ok, dom_node} -> dom_node
      {:error, message} -> raise "Click could not connect to #{base_url}: #{inspect(message)}"
    end
  end

  def new(base_url, opts \\ []) do
    with node <- %DomNode{base_url: base_url, id: nil, pid: nil},
         {:ok, node} <- start_session(node),
         {:ok, node} <- update_user_agent(node, Keyword.get(opts, :user_agent_suffix)),
         {:ok, node} <- navigate(node, "/"),
         {:ok, node} <- get_current_document(node) do
      {:ok, node}
    end
  end

  #

  def get_current_document(%DomNode{pid: pid} = node) do
    with {:ok, %{"result" => %{"root" => %{"nodeId" => id}}}} <- RPC.DOM.getDocument(pid),
         node <- %{node | id: id} do
      {:ok, node}
    end
  end

  def navigate(%DomNode{base_url: base_url, pid: pid} = node, path) do
    event = "Page.domContentEventFired"

    subscribe(node, event)

    with {:ok, _} <- RPC.Page.enable(pid),
         url <- URI.merge(base_url, path) |> to_string(),
         {:ok, _} <- RPC.Page.navigate(pid, %{url: url}) do
      receive do
        {:chrome_remote_interface, event, _response} ->
          unsubscribe(node, event)
          {:ok, node}
      after
        2_000 ->
          unsubscribe(node, event)
          {:error, "page did not load after navigating to #{url}"}
      end
    end
  end

  def simulate_click(%DomNode{} = node) do
    Chrome.scroll_into_view(node)

    [x, y] = node |> Chrome.get_box_model() |> Quad.center()

    node
    |> Chrome.dispatch_mouse_event("mouseMoved", x, y, "none")
    |> Chrome.dispatch_mouse_event("mousePressed", x, y, "left")
    |> Chrome.dispatch_mouse_event("mouseReleased", x, y, "left")
  end

  def simulate_keypress(%DomNode{} = node, key_code) do
    node
    |> Chrome.dispatch_key_event("keyDown", key_code)
    |> Chrome.dispatch_key_event("keyUp", key_code)
  end

  def wait_for_navigation(%DomNode{} = node, fun) do
    event = "Page.frameNavigated"

    subscribe(node, event)

    fun.()

    receive do
      {:chrome_remote_interface, event, _response} ->
        unsubscribe(node, event)
        {:ok, node} = wait_for_and_get_current_document(node)
        node
    after
      500 ->
        unsubscribe(node, event)
        {:error, "timeout while waiting for page navigation"}
    end
  end

  def wait_for_and_get_current_document(%DomNode{} = node) do
    event = "Page.domContentEventFired"

    subscribe(node, event)

    receive do
      {:chrome_remote_interface, event, _response} ->
        unsubscribe(node, event)
        get_current_document(node)
    after
      2_000 ->
        unsubscribe(node, event)
        {:error, "page did not load"}
    end
  end

  def start_session(%DomNode{} = node) do
    with ws_addr <- Chroxy.connection(),
         {:ok, pid} <- PageSession.start_link(ws_addr) do
      {:ok, %{node | pid: pid}}
    end
  end

  def update_user_agent(browser, nil), do: {:ok, browser}

  def update_user_agent(%DomNode{pid: pid} = node, suffix) do
    with {:ok, %{"result" => %{"userAgent" => user_agent}}} <- RPC.Browser.getVersion(pid),
         {:ok, _} <- RPC.Network.setUserAgentOverride(pid, %{"userAgent" => user_agent <> suffix}) do
      {:ok, node}
    end
  end

  #

  defp subscribe(%DomNode{pid: pid}, event) do
    :ok = PageSession.subscribe(pid, event)
  end

  defp unsubscribe(%DomNode{pid: pid}, event) do
    :ok = PageSession.unsubscribe(pid, event)
  end
end
