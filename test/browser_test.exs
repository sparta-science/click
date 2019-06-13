defmodule Click.BrowserTest do
  use ExUnit.Case, async: false

  describe "new" do
    test "user agent" do
      [user_agent] = Click.new_browser() |> Click.navigate("/info") |> Click.find_first("user-agent") |> Click.text()
      assert user_agent |> String.ends_with?("foo")
    end
  end
end
