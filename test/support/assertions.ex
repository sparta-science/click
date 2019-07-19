defmodule Click.Assertions do
  import ExUnit.Assertions

  def assert_eq(a, b),
    do: assert(a == b)
end
