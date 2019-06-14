defmodule Click.NodeDescription do
  def extract_text(%{"children" => children}),
    do: children |> Enum.reduce([], &extract_text/2) |> Enum.reverse()

  defp extract_text(%{"children" => children}, list),
    do: children |> Enum.reduce(list, &extract_text/2)

  defp extract_text(%{"nodeName" => "#text", "nodeValue" => text}, list),
    do: [text | list]

  defp extract_text(%{} = _other, list),
    do: list
end
