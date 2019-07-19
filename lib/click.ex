defmodule Click do
  import Click.Context, only: [with_browser: 2, with_nodes: 2, with_one_node: 2]
  import Click.Ok, only: [ok!: 1]

  alias Click.Browser
  alias Click.Chrome
  alias Click.ChromeEvent
  alias Click.NodeDescription
  alias Click.Simulate

  @full_depth -1

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def connect(opts \\ []) do
    Browser.new(
      opts |> Keyword.get(:base_url, "http://localhost:4001"),
      user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
    )
    |> ok!()
  end

  def attr(context, attr_name),
    do: context |> with_nodes(&Chrome.get_attributes(&1, attr_name)) |> ok!()

  def attr(context, attr_name, value),
    do: context |> with_nodes(&Chrome.set_attribute(&1, attr_name, value)) |> ok!()

  def call(context, javascript),
    do: context |> with_nodes(&Chrome.call_function_on(&1, javascript)) |> ok!()

  def click(context),
    do: context |> with_one_node(&eval(&1, "this.click()")) |> ok!()

  def click(context, :wait_for_navigation),
    do: context |> with_one_node(fn context -> ChromeEvent.wait_for_navigation(context, &click/1, &Chrome.get_document/1) end) |> ok!()

  def current_path(context),
    do: context |> with_browser(&eval(&1, "return window.location.pathname")) |> ok!()

  def eval(context, javascript),
    do: context |> with_browser(&Chrome.evaluate(&1, javascript)) |> ok!()

  def filter(context, text: text),
    do: context |> Enum.filter(&(text(&1) == text))

  def find_all(context, query),
    do: context |> with_nodes(&(Chrome.query_selector_all(&1, query) |> ok!()))

  def find_first(context, query),
    do: context |> with_nodes(&(Chrome.query_selector(&1, query) |> ok!()))

  def html(nodes),
    do: nodes |> with_nodes(&Chrome.get_outer_html/1) |> ok!()

  @doc """
  Navigates to a relative path and returns a context containing the browser and the root dom node of the new page.
  """
  def navigate(context, path),
    do: context |> with_browser(fn browser -> {browser, Browser.navigate(browser, path) |> ok!()} end)

  def pdf(context),
    do: context |> with_one_node(&Chrome.print_to_pdf/1) |> ok!()

  def screenshot(context),
    do: context |> with_one_node(&Chrome.capture_screenshot/1) |> ok!()

  def send_enter(context),
    do: context |> with_nodes(&Simulate.keypress(&1, :enter)) |> ok!()

  @doc """
  Returns the text content of the node or nodes. If a node is visible, some styling such as text-transform will be applied.
  If a node is not visible, styling is not applied but the text is still returned. (This is unfortunately how Chrome works.)
  """
  def text(context),
    do: context |> with_nodes(&Click.call(&1, "return this.innerText")) |> ok!()

  @doc """
  Returns the raw text of the node or nodes. No styling is applied, and newlines and other spacing are not preserved.
  """
  def text(context, :raw, depth \\ @full_depth),
    do: context |> with_nodes(&(Chrome.describe_node(&1, depth) |> ok!() |> NodeDescription.extract_text()))

  def wait_for_navigation(context, fun),
    do: ChromeEvent.wait_for_navigation(context, fun, &Chrome.get_document/1) |> ok!()

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"
end
