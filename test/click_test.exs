defmodule Click.ClickTest do
  use ExUnit.Case, async: false

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.TestPlug

  describe "attr" do
    test "gets the specified attr" do
      attrs = Click.new_browser() |> Click.navigate("/attrs") |> Click.attr("data-role")
      assert attrs == ["top", "inner", "bottom"]
    end
  end

  describe "find_all" do
    test "gets all the matching nodes" do
      browser = Click.new_browser() |> Click.find_all("h2")
      assert length(browser.nodes) == 2
      assert Click.text(browser) == ["Lorem", "Ipsum"]
    end
  end

  describe "find_first" do
    test "gets  the first matching node" do
      browser = Click.new_browser() |> Click.find_first("h2")
      assert length(browser.nodes) == 1
      assert browser |> Click.text() == ["Lorem"]
    end
  end

  describe "html" do
    test "returns the HTML source of a page" do
      html = Click.new_browser() |> Click.html()
      assert normalize(html) == normalize([TestPlug.home_page()])
    end
  end

  describe "navigate" do
    test "navigates to another page" do
      heading = Click.new_browser() |> Click.navigate("/page-two") |> Click.find_first("h1") |> Click.text()
      assert heading == ["Page Two"]
    end
  end

  describe "new_browser" do
    test "can append metadata to the user agent string" do
      [user_agent] =
        Click.new_browser(metadata: "glorp")
        |> Click.navigate("/info")
        |> Click.find_first("user-agent")
        |> Click.text()

      assert user_agent =~ ~r|.*/BeamMetadata \(g2gCZAACdjFtAAAABWdsb3Jw\)$|
    end
  end

  describe "text" do
    test "gets the text of a single element" do
      header = Click.new_browser() |> Click.find_first("h2") |> Click.text()
      assert header == ["Lorem"]
    end

    test "gets the text of multiple  elements" do
      headers = Click.new_browser() |> Click.find_all("h2") |> Click.text()
      assert headers == ["Lorem", "Ipsum"]
    end
  end
end
