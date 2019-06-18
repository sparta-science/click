defmodule Click do
  alias Click.Browser
  alias Click.Chrome
  alias Click.Quad
  alias Click.DomNode
  alias Click.NodeDescription

  @full_depth -1

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def connect(opts \\ []) do
    Browser.new(
      "http://localhost:4001",
      user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
    )
  end

  def attr(nodes, attr_name),
    do: nodes |> with_nodes(&(Chrome.get_attributes(&1) |> Map.get(attr_name)))

  def click(%DomNode{pid: pid} = node) do
    :ok = ChromeRemoteInterface.PageSession.subscribe(pid, "Page.frameNavigated")

    [x, y] = node |> Chrome.get_box_model() |> Quad.center()

    node |> Chrome.dispatch_mouse_event("mouseMoved", x, y, "none")
    node |> Chrome.dispatch_mouse_event("mousePressed", x, y, "left")
    node |> Chrome.dispatch_mouse_event("mouseReleased", x, y, "left")

    receive do
      {:chrome_remote_interface, "Page.frameNavigated", _response} ->
        ChromeRemoteInterface.PageSession.unsubscribe(pid, "Page.frameNavigated")
        {:ok, node} = wait_for_and_get_document(node)
        node
    after
      500 ->
        ChromeRemoteInterface.PageSession.unsubscribe(pid, "Page.frameNavigated")
        IO.puts("no frame navigated")
    end
  end

  def wait_for_and_get_document(%DomNode{pid: pid} = node) do
    :ok = ChromeRemoteInterface.PageSession.subscribe(pid, "Page.domContentEventFired")

    receive do
      {:chrome_remote_interface, "Page.domContentEventFired", _response} ->
        :ok = ChromeRemoteInterface.PageSession.unsubscribe(pid, "Page.domContentEventFired")
        Browser.get_document(node)
    after
      2_000 ->
        :ok = ChromeRemoteInterface.PageSession.unsubscribe(pid, "Page.domContentEventFired")
        {:error, "Timeout waiting for Page.domContentEventFired"}
    end
  end

  def filter(nodes, text: text),
    do: nodes |> Enum.filter(&(text(&1, 1) == text))

  def find_all(nodes, query),
    do: nodes |> List.wrap() |> Enum.flat_map(&Chrome.query_selector_all(&1, query))

  def find_first(nodes, query),
    do: nodes |> find_all(query) |> List.first()

  def html(nodes),
    do: nodes |> with_nodes(&Chrome.get_outer_html(&1))

  def navigate(%DomNode{} = node, path) do
    with {:ok, node} <- Browser.navigate(node, path),
         {:ok, node} <- Browser.get_document(node) do
      node
    end
  end

  def text(nodes, depth \\ @full_depth),
    do: nodes |> with_nodes(&(Chrome.describe_node(&1, depth) |> NodeDescription.extract_text()))

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"

  defp with_nodes(nil, _fun),
    do: nil

  defp with_nodes(nodes, fun) when is_list(nodes),
    do: nodes |> Enum.map(fun)

  defp with_nodes(node, fun),
    do: fun.(node)
end
