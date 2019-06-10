defmodule Click do
  alias ChromeRemoteInterface.RPC.DOM
  alias Click.Browser
  alias Click.Extra

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
    retry(fn ->
      new_nodes =
        nodes
        |> Enum.map(fn node ->
          with {:ok, %{"result" => %{"nodeIds" => node_ids}}} <- DOM.querySelectorAll(pid, %{"nodeId" => node, "selector" => query}) do
            node_ids
          end
        end)
        |> List.flatten()

      %{browser | nodes: new_nodes}
    end)
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
    retry(fn ->
      nodes
      |> Enum.map(fn node ->
        with {:ok, %{"result" => %{"outerHTML" => outer_html}}} <- DOM.getOuterHTML(pid, %{"nodeId" => node}) do
          outer_html
        end
      end)
      |> List.flatten()
    end)
  end

  def text(%Browser{pid: pid, nodes: nodes}) do
    nodes
    |> Enum.map(fn node ->
      with {:ok, %{"result" => %{"node" => %{"children" => children}}}} <- DOM.describeNode(pid, %{"nodeId" => node, "depth" => -1}) do
        children
        |> Enum.map(fn
          %{"nodeName" => "#text", "nodeValue" => text} -> text
          _ -> nil
        end)
      end
    end)
    |> List.flatten()
    |> Extra.Enum.compact()
  end

  defp retry(fun, count \\ 10) do
    case fun.() do
      {:ok, result} ->
        {:ok, result}

      result ->
        if count == 0,
          do: result,
          else: :timer.sleep(100) && retry(fun, count - 1)
    end
  end
end
