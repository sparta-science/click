defmodule Click.Browser do
  alias ChromeRemoteInterface.PageSession
  alias ChromeRemoteInterface.RPC.DOM
  alias ChromeRemoteInterface.RPC.Page
  alias ChromeRemoteInterface.Session
  alias Click.Browser
  alias Click.Chrome

  defstruct ~w{base_url pid root_node nodes}a

  def new(base_url) do
    with browser <- %Browser{base_url: base_url, pid: nil, root_node: nil, nodes: []},
         {:ok, browser} <- start_session(browser),
         {:ok, browser} <- navigate(browser, "/"),
         {:ok, browser} <- get_document(browser) do
      browser
    end
  end

  def get_document(%Browser{pid: pid} = browser) do
    with {:ok, %{"result" => %{"root" => %{"nodeId" => root_node_id}}}} <- DOM.getDocument(pid),
         browser <- %{browser | root_node: root_node_id, nodes: [root_node_id]} do
      {:ok, browser}
    end
  end

  def navigate(%Browser{base_url: base_url, pid: pid} = browser, path) do
    with {:ok, _} <- Page.enable(pid),
         :ok <- PageSession.subscribe(pid, "Page.loadEventFired"),
         url <- URI.merge(base_url, path) |> to_string(),
         {:ok, _} <- Page.navigate(pid, %{url: url}) do
      receive do
        {:chrome_remote_interface, "Page.loadEventFired", _response} ->
          :ok = PageSession.unsubscribe(pid, "Page.loadEventFired")
          {:ok, browser}
      after
        250 ->
          :ok = PageSession.unsubscribe(pid, "Page.loadEventFired")
          {:error, "Timeout waiting for Page.loadEventFired for navigating to #{url}"}
      end
    end
  end

  def start_session(%Browser{} = browser) do
    with {:ok, [first_page | _]} <- Session.new(port: 9222) |> Session.list_pages(),
         {:ok, pid} <- PageSession.start_link(first_page) do
      {:ok, %{browser | pid: pid}}
    end
  end
end
