defmodule Click do
  alias Click.Browser
  alias Click.Chrome

  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(scheme: :http, plug: Click.TestPlug, options: [port: 4001])
    ]

    opts = [strategy: :one_for_one, name: Click.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def new_browser() do
    Browser.new("http://localhost:4001")
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

  def text(%Browser{pid: pid, nodes: nodes}) do
    Chrome.describe_node(pid, nodes, -1)
    |> Enum.map(& &1["children"])
    |> List.flatten()
    |> Enum.filter(&(&1["nodeName"] == "#text"))
    |> Enum.map(& &1["nodeValue"])
  end

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
