defmodule Click.BrowserSession do
  alias ChromeRemoteInterface.PageSession
  alias Click.Browser
  alias Click.Chrome

  def start(%Browser{} = browser) do
    with ws_addr <- Chroxy.connection(),
         {:ok, pid} <- PageSession.start_link(ws_addr) do
      {:ok, %{browser | pid: pid}}
    end
  end

  def update_user_agent(_browser, nil),
    do: :ok

  def update_user_agent(%Browser{} = browser, suffix) do
    with {:ok, user_agent} <- Chrome.get_user_agent(browser) do
      Chrome.set_user_agent(browser, user_agent <> suffix)
    end
  end
end
