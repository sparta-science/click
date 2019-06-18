defmodule Click.NodeDescription do
  def extract_text(%{"children" => _children} = node_description),
    do: node_description |> extract_raw_text() |> Enum.map(&String.trim/1) |> Enum.join(" ")

  def extract_raw_text(%{"children" => children}),
    do: children |> Enum.reduce([], &extract_raw_text/2) |> Enum.reverse()

  defp extract_raw_text(%{"children" => children}, list),
    do: children |> Enum.reduce(list, &extract_raw_text/2)

  defp extract_raw_text(%{"nodeName" => "#text", "nodeValue" => text}, list),
    do: [text | list]

  defp extract_raw_text(%{} = _other, list),
    do: list
end
