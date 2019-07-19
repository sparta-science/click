defmodule Click.DomNode do
  alias Click.DomNode

  defstruct ~w{id}a

  def new(node_id),
    do: %DomNode{id: node_id}
end
