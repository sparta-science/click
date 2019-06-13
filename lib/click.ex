defmodule Click do
  alias Click.Browser
  alias Click.Chrome

  def start(_type, _args) do
    Supervisor.start_link([], strategy: :one_for_one, name: Click.Supervisor)
  end

  def new_browser(opts \\ []) do
    Browser.new(
      "http://localhost:4001",
      user_agent_suffix: opts |> Keyword.get(:metadata) |> beam_metadata()
    )
  end

  def attr(browser, attr_name) do
    with %Browser{pid: pid, nodes: nodes} <- find_all(browser, "[#{attr_name}]"),
         attributes <- Chrome.get_attributes(pid, nodes) do
      Enum.map(attributes, &Map.get(&1, attr_name))
    end
  end

  def find_all(%Browser{pid: pid, nodes: nodes} = browser, query) do
    %{browser | nodes: Chrome.query_selector_all(pid, nodes, query)}
  end

  def find_first(browser, query) do
    browser |> find_all(query) |> first()
  end

  def first(%Browser{nodes: []} = browser) do
    browser
  end

  def first(%Browser{nodes: [first | _]} = browser) do
    %{browser | nodes: [first]}
  end

  def html(%Browser{pid: pid, nodes: nodes}) do
    Chrome.get_outer_html(pid, nodes)
  end

  def navigate(browser, path) do
    with {:ok, browser} <- Browser.navigate(browser, path),
         {:ok, browser} <- Browser.get_document(browser) do
      browser
    end
  end

  def text(%Browser{pid: pid, nodes: nodes}) do
    Chrome.describe_node(pid, nodes, -1)
    |> Enum.map(& &1["children"])
    |> List.flatten()
    |> Enum.filter(&(&1["nodeName"] == "#text"))
    |> Enum.map(& &1["nodeValue"])
  end

  #

  defp beam_metadata(nil),
    do: nil

  defp beam_metadata(metadata),
    do: "/BeamMetadata (#{{:v1, metadata} |> :erlang.term_to_binary() |> Base.url_encode64()})"

  #  defp retry(fun, count \\ 10) do
  #    case fun.() do
  #      {:ok, result} ->
  #        {:ok, result}
  #
  #      result ->
  #        if count == 0,
  #          do: result,
  #          else: :timer.sleep(100) && IO.write("®") && retry(fun, count - 1)
  #    end
  #  end
end
