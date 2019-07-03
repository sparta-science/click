defmodule ClickTest do
  use ExUnit.Case, async: false

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.DomNode
  alias Click.TestSupport.TestPlug

  describe "attr" do
    test "gets the specified attrs from the passed in nodes" do
      root = Click.connect() |> Click.navigate("/attrs")

      assert root |> Click.find_all("div") |> Click.attr("data-role") == ["top", "inner", "bottom", nil]
      assert root |> Click.find_first("div.topper") |> Click.attr("data-role") == "top"
    end
  end

  describe "click" do
    # https://medium.com/@aslushnikov/automating-clicks-in-chromium-a50e7f01d3fb

    test "sends mouse click events" do
      links_page = Click.connect() |> Click.navigate("/links")
      links_page |> Click.find_first("a#page-two") |> Click.click()
      {:ok, page_two} = Click.Browser.get_document(links_page)
      assert normalize(Click.html(page_two)) == normalize(TestPlug.page_two())
    end

    test "finds and clicks links that are off the bottom of the page" do
      links_page = Click.connect() |> Click.navigate("/links")
      links_page |> Click.find_first("a#home") |> Click.click()
      {:ok, home} = Click.Browser.get_document(links_page)
      assert normalize(Click.html(home)) == normalize(TestPlug.home_page())
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

  describe "filter" do
    test "can filter a list of nodes by their text contents" do
      nodes = Click.connect() |> Click.find_all("h2") |> Click.filter(text: "Ipsum")
      assert length(nodes) == 1
      assert Click.text(nodes) == ["Ipsum"]
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

  describe "wait_until" do
    test "loops on any error" do
      test_fun = fn -> raise ArithmeticError end

      assert_raise(ArithmeticError, fn ->
        Click.wait_until(test_fun, timeout: 0)
      end)
    end

    test "keeps trying for some number of milliseconds, and then raises" do
      test_fun = fn -> raise ArithmeticError end
      start_time = Click.now_ms()

      assert_raise ArithmeticError, fn ->
        Click.wait_until(test_fun, timeout: 5)
      end

      end_time = Click.now_ms()
      assert end_time - start_time >= 5
    end

    test "returns the result of the function if it does not raise" do
      test_fun = fn -> :success end

      assert Click.wait_until(test_fun, timeout: 0) == :success
    end
  end
end
