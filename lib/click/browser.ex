defmodule Click.Browser do
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC
  alias Click.Chrome
  alias Click.ChromeEvent
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
         {:ok, node} <- navigate(node, "/") do
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

  def navigate(node, path) do
    ChromeEvent.wait_for_navigation(node, &Chrome.navigate(&1, path), &get_current_document/1)
  end

  def simulate_click(%DomNode{} = node) do
    Chrome.scroll_into_view(node)

    [x, y] = node |> Chrome.get_box_model() |> Quad.center()

    node
    |> Chrome.dispatch_mouse_event("mouseMoved", x, y, "none")
    |> Chrome.dispatch_mouse_event("mousePressed", x, y, "left")
    |> Chrome.dispatch_mouse_event("mouseReleased", x, y, "left")
  end

  def simulate_keypress(%DomNode{} = node, :enter) do
    # see https://github.com/GoogleChrome/puppeteer/blob/master/lib/USKeyboardLayout.js#L32
    # and https://github.com/GoogleChrome/puppeteer/blob/master/lib/Input.js#L176

    node
    |> Chrome.focus()
    |> Chrome.dispatch_key_event("keyDown", "Enter", 13, "Enter", "\r")
    |> Chrome.dispatch_key_event("keyUp", "Enter", 13, "Enter", "\r")
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
end
