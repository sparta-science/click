defmodule Click.ClickTest do
  use ExUnit.Case, async: false

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.Node
  alias Click.TestPlug

  describe "attr" do
    test "gets the specified attr" do
      attrs = Click.connect() |> Click.navigate("/attrs") |> Click.attr("data-role")
      assert attrs == ["top", "inner", "bottom"]
    end
  end

  describe "find_all" do
    test "gets all the matching nodes" do
      nodes = Click.connect() |> Click.find_all("h2")
      assert length(nodes) == 2
      assert Click.text(nodes) == ["Lorem", "Ipsum"]
    end
  end

  describe "find_first" do
    test "gets  the first matching node" do
      node = Click.connect() |> Click.find_first("h2")
      assert %Node{} = node
      assert node |> Click.text() == ["Lorem"]
    end
  end

  describe "html" do
    test "returns the HTML source of a page" do
      html = Click.connect() |> Click.html()
      assert normalize(html) == normalize([TestPlug.home_page()])
    end
  end

  describe "navigate" do
    test "navigates to another page" do
      heading = Click.connect() |> Click.navigate("/page-two") |> Click.find_first("h1") |> Click.text()
      assert heading == ["Page Two"]
    end
  end

  describe "connect" do
    test "can append metadata to the user agent string" do
      [user_agent] =
        Click.connect(metadata: "glorp")
        |> Click.navigate("/info")
        |> Click.find_first("user-agent")
        |> Click.text()

      assert user_agent =~ ~r|.*/BeamMetadata \(g2gCZAACdjFtAAAABWdsb3Jw\)$|
    end
  end

  describe "text" do
    test "gets the text of a single element" do
      header = Click.connect() |> Click.find_first("h2") |> Click.text()
      assert header == ["Lorem"]
    end

    test "gets the text of multiple  elements" do
      headers = Click.connect() |> Click.find_all("h2") |> Click.text()
      assert headers == ["Lorem", "Ipsum"]
    end
  end
end
