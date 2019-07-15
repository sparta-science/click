defmodule Click.BrowserSession do
  alias ChromeRemoteInterface.PageSession
  alias Click.Chrome
  alias Click.DomNode

  def start(%DomNode{} = node) do
    with ws_addr <- Chroxy.connection(),
         {:ok, pid} <- PageSession.start_link(ws_addr) do
      {:ok, %{node | pid: pid}}
    end
  end

  def update_user_agent(node, nil),
    do: {:ok, node}

  def update_user_agent(%DomNode{} = node, suffix) do
    with {:ok, user_agent} <- Chrome.get_user_agent(node) do
      Chrome.set_user_agent(node, user_agent <> suffix)
    end
  end
end
