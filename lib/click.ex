defmodule Click do
  import Click.DomNode, only: [one!: 1, with_nodes: 2]
  import Click.Ok, only: [ok!: 1]

  alias Click.Browser
  alias Click.Chrome
  alias Click.ChromeEvent
  alias Click.NodeDescription
  alias Click.Properties
  alias Click.Simulate

  @full_depth -1

  def start(_type, _args) do
    check_chrome_remote_interface_version!()
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
    do: nodes |> with_nodes(&Chrome.get_attributes(&1, attr_name)) |> ok!()

  def attr(nodes, attr_name, value),
    do: nodes |> with_nodes(&Chrome.set_attribute(&1, attr_name, value)) |> ok!()

  def click(node),
    do: node |> one!() |> call("this.scrollIntoView(); this.click();") |> ok!() |> return(node)

  def click(node, :wait_for_load),
    do: node |> one!() |> ChromeEvent.wait_for_load(&click/1, &Browser.get_current_document/1) |> ok!()

  def click(node, :wait_for_navigation),
    do: node |> one!() |> ChromeEvent.wait_for_navigation(&click/1, &Browser.get_current_document/1) |> ok!()

  def current_path(node),
    do: node |> one!() |> call("return window.location.pathname") |> ok!()

  def call(node, javascript),
    do: Chrome.call_function_on(node, javascript) |> ok!()

  def eval(node, javascript),
    do: Chrome.evaluate(node, javascript) |> ok!()

  def filter(nodes, text: text),
    do: nodes |> Enum.filter(&(text(&1) == text))

  def find_all(nodes, query),
    do: nodes |> find_all(query, :include_invisible) |> Enum.filter(&visible?/1) |> ok!()

  def find_all(nodes, query, :include_invisible),
    do: nodes |> List.wrap() |> Enum.flat_map(&(Chrome.query_selector_all(&1, query) |> ok!()))

  def find_first(nodes, query),
    do: nodes |> find_all(query) |> List.first() |> ok!()

  def html(nodes),
    do: nodes |> with_nodes(&Chrome.get_outer_html/1) |> ok!()

  def navigate(node, path),
    do: one!(node) |> Browser.navigate(path) |> ok!()

  def pdf(node),
    do: one!(node) |> Chrome.print_to_pdf() |> ok!()

  def reload(node),
    do: one!(node) |> ChromeEvent.wait_for_load(&Chrome.reload/1, &Browser.get_current_document/1) |> ok!()

  def screenshot(node),
    do: node |> one!() |> Chrome.capture_screenshot() |> ok!()

  def send_enter(nodes),
    do: nodes |> with_nodes(&Simulate.keypress(&1, :enter)) |> ok!()

  @doc """
  Returns the text content of the node or nodes. If a node is visible, some styling such as text-transform will be applied.
  If a node is not visible, styling is not applied but the text is still returned. (This is unfortunately how Chrome works.)
  """
  def text(nodes),
    do: nodes |> with_nodes(&Click.call(&1, "return this.innerText")) |> ok!()

  @doc """
  Returns the raw text of the node or nodes. No styling is applied, and newlines and other spacing are not preserved.
  """
  def text(nodes, :raw, depth \\ @full_depth),
    do: nodes |> with_nodes(&(Chrome.describe_node(&1, depth) |> ok!() |> NodeDescription.extract_text()))

  def visible?(node),
    do: node |> one!() |> Chrome.get_properties() |> ok!() |> Properties.get(["offsetWidth", "offsetHeight"]) |> Enum.all?(&(&1 > 0))

  def wait_for_navigation(nodes, fun),
    do: ChromeEvent.wait_for_navigation(nodes, fun, &Browser.get_current_document/1) |> ok!()

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"

  defp return(_, value),
    do: value

  defp check_chrome_remote_interface_version!() do
    version = ChromeRemoteInterface.protocol_version()

    unless version == "tot" do
      raise """
        Expected Chrome Remote Interface protocol version to be “tot” but was “#{version}”.
        Make sure environment variable CRI_PROTOCOL_VERSION is set to “tot” **before** compiling Click's dependencies.
      """
    end
  end
end
