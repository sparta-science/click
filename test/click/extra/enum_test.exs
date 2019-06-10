defmodule Click.Extra.EnumTest do
  use ExUnit.Case, async: true

  alias Click.Extra

  describe "compact/1" do
    test "removes nil elements" do
      assert [1, nil, 3] |> Extra.Enum.compact() == [1, 3]
    end
  end
end
