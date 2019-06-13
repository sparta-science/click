defmodule Click.ClickTest do
  use ExUnit.Case, async: true

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.TestPlug

  setup_all do
    start_supervised(Plug.Cowboy.child_spec(scheme: :http, plug: Click.TestPlug, options: [port: 4001]))
    :ok
  end

  setup do
    [browser: Click.new_browser()]
  end

  describe "html" do
    test "returns the HTML source of a page", %{browser: browser} do
      html = browser |> Click.html()
      assert normalize(html) == normalize([TestPlug.home_page()])
    end
  end

  describe "find_first" do
    test "gets  the first matching node", %{browser: browser} do
      browser = browser |> Click.find_first("h2")
      assert length(browser.nodes) == 1
      assert browser |> Click.text() == ["Lorem"]
    end
  end

  describe "find_all" do
    test "gets all the matching nodes", %{browser: browser} do
      browser = browser |> Click.find_all("h2")
      assert length(browser.nodes) == 2
      assert Click.text(browser) == ["Lorem", "Ipsum"]
    end
  end

  describe "text" do
    test "gets the text of a single element", %{browser: browser} do
      header = browser |> Click.find_first("h2") |> Click.text()
      assert header == ["Lorem"]
    end

    test "gets the text of multiple  elements", %{browser: browser} do
      headers = browser |> Click.find_all("h2") |> Click.text()
      assert headers == ["Lorem", "Ipsum"]
    end
  end
end
