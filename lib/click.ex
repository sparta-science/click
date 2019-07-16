defmodule Click do
  import Click.DomNode, only: [one!: 1, with_nodes: 2]
  import Click.Ok, only: [ok!: 1]

  alias Click.Browser
  alias Click.Chrome
  alias Click.ChromeEvent
  alias Click.NodeDescription
  alias Click.Simulate
  alias Click.Tempfile

  @full_depth -1

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def connect(opts \\ []) do
    Browser.new!(
      opts |> Keyword.get(:base_url, "http://localhost:4001"),
      user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
    )
    |> ok!()
  end

  def attr(nodes, attr_name),
    do: nodes |> with_nodes(&(Chrome.get_attributes(&1) |> ok!() |> Map.get(attr_name)))

  def attr(nodes, attr_name, value),
    do: nodes |> with_nodes(&Chrome.set_attribute(&1, attr_name, value)) |> ok!()

  def click(node),
    do: node |> one!() |> eval("this.click()") |> ok!()

  def click(node, :wait_for_navigation),
    do: node |> one!() |> ChromeEvent.wait_for_navigation(&click/1, &Browser.get_current_document/1) |> ok!()

  def eval(node, javascript),
    do: Chrome.call_function_on(node, javascript) |> ok!()

  def filter(nodes, text: text),
    do: nodes |> Enum.filter(&(text(&1) == text))

  def find_all(nodes, query),
    do: nodes |> List.wrap() |> Enum.flat_map(&(Chrome.query_selector_all(&1, query) |> ok!()))

  def find_first(nodes, query),
    do: nodes |> find_all(query) |> List.first() |> ok!()

  def html(nodes),
    do: nodes |> with_nodes(&(Chrome.get_outer_html(&1) |> ok!()))

  def navigate(node, path),
    do: one!(node) |> Browser.navigate(path) |> ok!()

  def screenshot(node),
    do: node |> one!() |> Chrome.capture_screenshot() |> ok!() |> Base.decode64!() |> Tempfile.write(".png")

  def send_enter(nodes),
    do: nodes |> with_nodes(&Simulate.keypress(&1, :enter)) |> ok!()

  def text(nodes, depth \\ @full_depth),
    do: nodes |> with_nodes(&(Chrome.describe_node(&1, depth) |> ok!() |> NodeDescription.extract_text()))

  def wait_for_navigation(nodes, fun),
    do: ChromeEvent.wait_for_navigation(nodes, fun, &Browser.get_current_document/1) |> ok!()

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"
end
