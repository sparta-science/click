defmodule Click do
  alias Click.Browser
  alias Click.Chrome
  alias Click.DomNode
  alias Click.NodeDescription
  alias Click.Tempfile

  @full_depth -1

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def connect(opts \\ []) do
    wait_until(fn ->
      Browser.new!(
        opts |> Keyword.get(:base_url, "http://localhost:4001"),
        user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
      )
    end)
  end

  def attr(nodes, attr_name),
    do: nodes |> with_nodes(&(Chrome.get_attributes(&1) |> Map.get(attr_name)))

  def attr(nodes, attr_name, value),
    do: nodes |> with_nodes(&Chrome.set_attribute(&1, attr_name, value))

  def click(node),
    do: node |> one!() |> Browser.simulate_click()

  def click(node, :wait_for_navigation) do
    with {:ok, node} <- node |> one!() |> Browser.wait_for_navigation(&Browser.simulate_click/1) do
      node
    else
      result -> raise "click navigation failed with #{inspect(result)}"
    end
  end

  def filter(nodes, text: text),
    do: nodes |> Enum.filter(&(text(&1) == text))

  def find_all(nodes, query),
    do: nodes |> List.wrap() |> Enum.flat_map(&Chrome.query_selector_all(&1, query))

  def find_first(nodes, query),
    do: nodes |> find_all(query) |> List.first()

  def html(nodes),
    do: nodes |> with_nodes(&Chrome.get_outer_html(&1))

  def navigate(node, path) do
    with node <- one!(node),
         {:ok, node} <- Browser.navigate(node, path) do
      node
    else
      result -> raise "navigation to #{path} failed with #{inspect(result)}"
    end
  end

  def screenshot(node),
    do: node |> one!() |> Chrome.capture_screenshot() |> Base.decode64!() |> Tempfile.write(".png")

  def send_enter(nodes),
    do: nodes |> with_nodes(&Browser.simulate_keypress(&1, :enter))

  def text(nodes, depth \\ @full_depth),
    do: nodes |> with_nodes(&(Chrome.describe_node(&1, depth) |> NodeDescription.extract_text()))

  def wait_until(fun, opts \\ []) when is_function(fun) and is_list(opts) do
    start_time = now_ms()

    try do
      fun.()
    rescue
      e -> process_error(fun, start_time, e, opts)
    end
  end

  defp process_error(fun, start_time, error, opts) do
    timeout = Keyword.get(opts, :timeout, 500)

    if timeout > 0 do
      :timer.sleep(5)
      elapsed = now_ms() - start_time
      wait_until(fun, timeout: max(0, timeout - elapsed))
    else
      raise error
    end
  end

  def now_ms(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"

  defp one!([%DomNode{} = node]),
    do: node

  defp one!(%DomNode{} = node),
    do: node

  defp with_nodes(nil, _fun),
    do: nil

  defp with_nodes(nodes, fun) when is_list(nodes),
    do: nodes |> Enum.map(fun)

  defp with_nodes(node, fun),
    do: fun.(node)
end
