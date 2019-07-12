defmodule Click.Browser do
  alias Click.BrowserSession
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
         {:ok, node} <- BrowserSession.start(node),
         {:ok, node} <- BrowserSession.update_user_agent(node, Keyword.get(opts, :user_agent_suffix)),
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
end
