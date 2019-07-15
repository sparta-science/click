defmodule Click.Ok do
  def ok!(list) when is_list(list), do: list |> Enum.map(&ok!/1)
  def ok!({:ok, ok}), do: ok
  def ok!(other_tuple) when is_tuple(other_tuple), do: raise("Expected {:ok, _}, got: #{inspect(other_tuple)}")
  def ok!(not_a_tuple), do: not_a_tuple
end
