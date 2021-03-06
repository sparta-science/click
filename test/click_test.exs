defmodule ClickTest do
  use ExUnit.Case, async: true

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.DomNode
  alias Click.TestSupport.TestPlug

  describe "attr" do
    test "gets the specified attrs from the passed in nodes" do
      root = Click.connect() |> Click.navigate("/attrs")

      assert root |> Click.find_all("div") |> Click.attr("data-role") == ["top", "inner", "bottom", nil]
      assert root |> Click.find_first("div.topper") |> Click.attr("data-role") == "top"
    end

    test "assigns the value to the attribute of the passed-in nodes" do
      root = Click.connect() |> Click.navigate("/form")
      assert root |> Click.find_all("input[type=text]") |> Click.attr("value") == ["", ""]
      root |> Click.find_all("input[type=text]") |> Click.attr("value", "glorp")
      assert root |> Click.find_all("input[type=text]") |> Click.attr("value") == ~w{glorp glorp}
    end
  end

  describe "click" do
    # https://medium.com/@aslushnikov/automating-clicks-in-chromium-a50e7f01d3fb

    test "sends mouse click events and waits for navigation" do
      links_page = Click.connect() |> Click.navigate("/links")
      page_two = links_page |> Click.find_first("a#page-two") |> Click.click(:wait_for_navigation)
      assert normalize(Click.html(page_two)) == normalize(TestPlug.load_page("/page-two"))

      {:ok, page_two} = Click.Browser.get_current_document(links_page)
      assert normalize(Click.html(page_two)) == normalize(TestPlug.load_page("/page-two"))
    end

    test "finds and clicks links that are off the bottom of the page" do
      links_page = Click.connect() |> Click.navigate("/links")
      home = links_page |> Click.find_first("a#home") |> Click.click(:wait_for_navigation)
      assert normalize(Click.html(home)) == normalize(TestPlug.load_page("/home"))

      {:ok, home} = Click.Browser.get_current_document(links_page)
      assert normalize(Click.html(home)) == normalize(TestPlug.load_page("/home"))
    end

    test "can click and wait for the page to load (even if naviation doesn't change)" do
      links_page = Click.connect() |> Click.navigate("/links")
      slow = links_page |> Click.find_first("a#slow") |> Click.click(:wait_for_load)
      assert slow |> Click.find_first("body") |> Click.attr("data-role") == "slow-page"
    end

    test "can click on things that don't result in page navigation" do
      form_page = Click.connect() |> Click.navigate("/form")
      first_checkbox = form_page |> Click.find_first("#checkbox-1:not(:checked)")
      clicked = first_checkbox |> Click.click()
      assert clicked == first_checkbox
      form_page |> Click.find_first("#checkbox-1:checked") |> assert
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

    test "can specify a base url" do
      dom_node = Click.connect(base_url: "http://localhost:4009")
      assert dom_node.base_url == "http://localhost:4009"
    end
  end

  describe "current_path" do
    test "returns the current path" do
      node = Click.connect()
      assert node |> Click.current_path() == "/"

      node = node |> Click.navigate("/form")
      assert node |> Click.current_path() == "/form"
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

    test "by default, only returns visible nodes, but can optionally include invisible ones" do
      page = Click.connect() |> Click.navigate("/hidden-elements")
      assert page |> Click.find_all("h1") |> Click.text() == ["Visible"]
      assert page |> Click.find_all("h1", :include_invisible) |> Click.text() == ["Visible", "Hidden"]
    end
  end

  describe "visible?" do
    test "returns true for visible nodes, false for hidden ones" do
      page = Click.connect() |> Click.navigate("/hidden-elements")

      {:ok, [node]} = Click.Chrome.query_selector_all(page, "#visible")
      assert node |> Click.visible?()

      {:ok, [node]} = Click.Chrome.query_selector_all(page, "#hidden")
      refute node |> Click.visible?()
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
      assert normalize(html) == normalize(TestPlug.load_page("/home"))
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

  describe "pdf" do
    test "gets base64 encoded pdf" do
      data = Click.connect() |> Click.navigate("/") |> Click.pdf()
      assert String.length(data) > 5_000
      assert {:ok, _} = Base.decode64(data)
    end
  end

  describe "reload" do
    test "reloads the page" do
      root = Click.connect() |> Click.navigate("/form")

      root |> Click.find_first("#text-field-1") |> Click.attr("value", "glorp")
      assert root |> Click.find_first("#text-field-1") |> Click.attr("value") == "glorp"

      root = root |> Click.reload()
      assert root |> Click.find_first("#text-field-1") |> Click.attr("value") == ""
    end
  end

  describe "screenshot" do
    test "gets base64 encoded screenshot" do
      data = Click.connect() |> Click.navigate("/") |> Click.screenshot()
      assert String.length(data) > 5_000
      assert {:ok, _} = Base.decode64(data)
    end
  end

  describe "send_enter" do
    test "sends a key event for the enter key" do
      page = Click.connect() |> Click.navigate("/events")
      page |> Click.find_first("#input") |> Click.send_enter()
      events = page |> Click.find_first("#output") |> Click.text()
      assert events == "keydown:Enter keyup:Enter"
    end
  end

  describe "text" do
    test "gets the text as displayed in the browser" do
      text = Click.connect() |> Click.navigate("/styled-text") |> Click.find_first("#level-1") |> Click.text()

      assert text ==
               """
               Start of level 1.
               START OF LEVEL 2.
               LEVEL 3.
               END OF LEVEL 2.
               End of level 1.
               """
               |> String.trim()
    end
  end

  describe "text (raw)" do
    test "by default, gets the text of all descendants, joined by a single space" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_first("#level-1") |> Click.text(:raw)
      assert text == "Start of level 1. Start of level 2. Level 3. End of level 2. End of level 1."
    end

    test "can get the text of any node depth" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_first("#level-1") |> Click.text(:raw, 1)
      assert text == "Start of level 1. End of level 1."
    end

    test "when given multiple nodes, gets text of each node and its descendants" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_all("div") |> Click.text(:raw)

      assert text == [
               "Start of level 1. Start of level 2. Level 3. End of level 2. End of level 1.",
               "Start of level 2. Level 3. End of level 2.",
               "Level 3."
             ]
    end

    test "when given multiple nodes, can get the text for each at any depth" do
      text = Click.connect() |> Click.navigate("/deep") |> Click.find_all("div") |> Click.text(:raw, 1)

      assert text == [
               "Start of level 1. End of level 1.",
               "Start of level 2. End of level 2.",
               "Level 3."
             ]
    end

    test "returns nil when getting the text of no elements" do
      assert nil |> Click.text(:raw) == nil
      assert [] |> Click.text(:raw) == []
    end
  end

  describe "wait_for_navigation" do
    test "returns the node of the new page" do
      node = Click.connect() |> Click.wait_for_navigation(&Click.navigate(&1, "/deep"))
      assert normalize(Click.html(node)) == normalize(TestPlug.load_page("/deep"))
    end

    test "raises if the navigation fails" do
      assert_raise(RuntimeError, fn ->
        Click.connect() |> Click.wait_for_navigation(fn _ -> nil end)
      end)
    end
  end
end
