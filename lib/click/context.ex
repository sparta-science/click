defmodule Click.Context do
  alias Click.Browser
  alias Click.DomNode

  def with_browser(%Browser{} = browser, fun) when is_function(fun),
    do: fun.(browser)

  def with_browser({%Browser{} = browser}, fun) when is_function(fun),
    do: fun.(browser)

  def with_browser({%Browser{} = browser, _node_or_nodes}, fun) when is_function(fun),
    do: fun.(browser)

  def with_nodes(%Browser{} = browser, _fun),
    do: browser

  def with_nodes({%Browser{} = browser}, _fun),
    do: {browser}

  def with_nodes({%Browser{} = browser, %DomNode{} = node}, fun) when is_function(fun),
    do: {browser, fun.({browser, node})}

  def with_nodes({%Browser{} = browser, nodes}, fun) when is_function(fun) when is_list(nodes),
    do: {browser, Enum.map(nodes, fn node -> fun.({browser, node}) end)}

  def with_one_node({%Browser{}, %DomNode{}} = tuple, fun) when is_function(fun),
    do: with_nodes(tuple, fun)

  def with_one_node({%Browser{}, [%DomNode{}]} = tuple, fun) when is_function(fun),
    do: with_nodes(tuple, fun)
end
