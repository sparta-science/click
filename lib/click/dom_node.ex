defmodule Click.DomNode do
  alias Click.DomNode

  defstruct ~w{base_url id pid}a

  def one!([%DomNode{} = node]),
    do: node

  def one!(%DomNode{} = node),
    do: node

  def with_nodes(nil, _fun),
    do: nil

  def with_nodes(nodes, fun) when is_list(nodes),
    do: nodes |> Enum.map(fun)

  def with_nodes(node, fun),
    do: fun.(node)
end

defimpl Inspect, for: Click.DomNode do
  import Inspect.Algebra

  def inspect(node, opts) do
    concat([
      "#Click.DomNode<",
      "\n  base_url: ",
      to_doc(node.base_url, opts),
      "\n  id: ",
      to_doc(node.id, opts),
      "\n  pid: ",
      to_doc(node.pid, opts),
      "\n  html:\n      ",
      Click.html(node),
      "\n>"
    ])
  end
end
