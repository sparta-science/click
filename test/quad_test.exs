defmodule Click.QuadTest do
  use ExUnit.Case, async: false

  alias Click.Quad

  describe "center" do
    test "returns the center for the quad" do
      quad = [1, 1, 5, 1, 5, 3, 1, 3]
      expected = [3, 2]

      assert Quad.center(quad) == expected
    end
  end
end
