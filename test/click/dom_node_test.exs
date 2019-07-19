defmodule Click.DomNodeTest do
  use ExUnit.Case, async: true

  describe "inspect" do
    test "allows inspection of a node" do
      inspected = Click.connect() |> Click.navigate("/deep") |> Click.find_first("#level-2") |> inspect()

      assert inspected =~ ~r|id: \d+|
      assert inspected =~ ~r|pid: #PID|
      assert inspected =~ ~r|<div id="level-2">|
    end
  end
end
