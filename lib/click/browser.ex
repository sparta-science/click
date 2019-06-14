defmodule Click.Browser do
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC
  alias ChromeRemoteInterface.Session
  alias Click.DomNode

  def new(base_url, opts \\ []) do
    with node <- %DomNode{base_url: base_url, id: nil, pid: nil},
         {:ok, node} <- start_session(node),
         {:ok, node} <- update_user_agent(node, Keyword.get(opts, :user_agent_suffix)),
         {:ok, node} <- navigate(node, "/"),
         {:ok, node} <- get_document(node) do
      node
    end
  end

  def start_session(%DomNode{} = node) do
    with {:ok, [first_page | _]} <- Session.new(port: 9222) |> Session.list_pages(),
         {:ok, pid} <- PageSession.start_link(first_page) do
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

  def navigate(%DomNode{base_url: base_url, pid: pid} = node, path) do
    with {:ok, _} <- RPC.Page.enable(pid),
         :ok <- PageSession.subscribe(pid, "Page.domContentEventFired"),
         url <- URI.merge(base_url, path) |> to_string(),
         {:ok, _} <- RPC.Page.navigate(pid, %{url: url}) do
      receive do
        {:chrome_remote_interface, "Page.domContentEventFired", _response} ->
          :ok = PageSession.unsubscribe(pid, "Page.domContentEventFired")
          {:ok, node}
      after
        2_000 ->
          :ok = PageSession.unsubscribe(pid, "Page.domContentEventFired")
          {:error, "Timeout waiting for Page.domContentEventFired for navigating to #{url}"}
      end
    end
  end

  def get_document(%DomNode{pid: pid} = node) do
    with {:ok, %{"result" => %{"root" => %{"nodeId" => id}}}} <- RPC.DOM.getDocument(pid),
         node <- %{node | id: id} do
      {:ok, node}
    end
  end
end
