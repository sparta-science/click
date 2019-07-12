defmodule Click.Browser do
  alias ChromeRemoteInterface.PageSession
  alias Click.Chrome
  alias Click.ChromeEvent
  alias Click.DomNode

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

  def get_current_document(%DomNode{} = node) do
    {:ok, Chrome.get_document(node)}
  end

  def navigate(node, path) do
    ChromeEvent.wait_for_navigation(node, &Chrome.navigate(&1, path), &get_current_document/1)
  end

  def start_session(%DomNode{} = node) do
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
