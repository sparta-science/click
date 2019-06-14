defmodule Click.Extra.List do
  def to_map(list),
    do: list |> Enum.chunk_every(2) |> Map.new(fn [k, v] -> {k, v} end)
end
