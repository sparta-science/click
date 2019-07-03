defmodule Click.BrowserTest do
  use ExUnit.Case, async: false

  alias Click.Browser

  describe "new" do
    test "user agent" do
      user_agent =
        Browser.new("http://localhost:4009", user_agent_suffix: "/glorp")
        |> Click.navigate("/info")
        |> Click.find_first("user-agent")
        |> Click.text()

      assert user_agent =~ ~r|.*/glorp$|
    end
  end
end
