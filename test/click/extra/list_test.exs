defmodule Click.Extra.ListTest do
  use ExUnit.Case, async: true

  alias Click.Extra

  describe "to_map/1" do
    test "converts [k1, v1, k2, v2, ...] to %{k1: v1, k2: v2, ...}" do
      assert [:a, 1, :b, 2, :c, 3] |> Extra.List.to_map() == %{a: 1, b: 2, c: 3}
    end
  end
end
