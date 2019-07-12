defmodule Click.Ok do
  def ok({:ok, ok}), do: ok
  def ok(not_a_tuple) when not is_tuple(not_a_tuple), do: not_a_tuple
  def ok(other), do: raise("Expected {:ok, _}, got: #{inspect(other)}")
end
