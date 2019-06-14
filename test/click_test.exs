defmodule Click.ClickTest do
  use ExUnit.Case, async: false

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.DomNode
  alias Click.TestPlug

  describe "attr" do
    test "gets the specified attr" do
      attrs = Click.connect() |> Click.navigate("/attrs") |> Click.attr("data-role")
      assert attrs == ["top", "inner", "bottom"]
    end
  end

  describe "connect" do
    test "can append metadata to the user agent string" do
      user_agent =
        Click.connect(metadata: "glorp")
        |> Click.navigate("/info")
        |> Click.find_first("user-agent")
        |> Click.text()

      assert user_agent =~ ~r|.*/BeamMetadata \(g2gCZAACdjFtAAAABWdsb3Jw\)$|
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
    test "gets the first matching node" do
      node = Click.connect() |> Click.find_first("h2")
      assert %DomNode{} = node
      assert node |> Click.text() == "Lorem"
    end

    test "returns nothing if there is no matching node" do
      assert Click.connect() |> Click.find_first("#glorp") == nil
    end
  end

  describe "html" do
    test "returns the HTML source of a page" do
      html = Click.connect() |> Click.html()
      assert normalize(html) == normalize(TestPlug.home_page())
    end

    test "returns the HTML source of an element" do
      html = Click.connect() |> Click.find_first("h1") |> Click.html()
      assert html == "<h1>Hello, world!</h1>"
    end

    test "returns the HTML source of multiple elements" do
      html = Click.connect() |> Click.find_all("h2") |> Click.html()
      assert html == ["<h2>Lorem</h2>", "<h2>Ipsum</h2>"]
    end

    test "returns nothing when there are no nodes" do
      assert nil |> Click.html() == nil
      assert [] |> Click.html() == []
    end
  end

  describe "navigate" do
    test "navigates to another page" do
      heading = Click.connect() |> Click.navigate("/page-two") |> Click.find_first("h1") |> Click.text()
      assert heading == "Page Two"
    end
  end

  describe "text" do
    test "by default, gets the text of all descendants, joined by a single space" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_first("#level-1") |> Click.text()
      assert text == "Start of level 1. Start of level 2. Level 3. End of level 2. End of level 1."
    end

    test "can get the text of any node depth" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_first("#level-1") |> Click.text(1)
      assert text == "Start of level 1. End of level 1."
    end

    test "when given multiple nodes, gets text of each node and its descendants" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_all("div") |> Click.text()

      assert text == [
               "Start of level 1. Start of level 2. Level 3. End of level 2. End of level 1.",
               "Start of level 2. Level 3. End of level 2.",
               "Level 3."
             ]
    end

    test "when given multiple nodes, can get the text for each at any depth" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_all("div") |> Click.text(1)

      assert text == [
               "Start of level 1. End of level 1.",
               "Start of level 2. End of level 2.",
               "Level 3."
             ]
    end

    test "returns nil when getting the text of no elements" do
      assert nil |> Click.text() == nil
      assert [] |> Click.text() == []
    end
  end
end
