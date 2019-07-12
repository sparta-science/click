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

  def update_user_agent(%DomNode{} = node, suffix),
    do: {:ok, Chrome.set_user_agent(node, Chrome.get_user_agent(node) <> suffix)}
end
