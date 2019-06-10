defmodule Click.Extra.Enum do
  def compact(enumerable) do
    Enum.reject(enumerable, &is_nil/1)
  end
end
