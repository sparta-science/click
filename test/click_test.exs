defmodule Click.ClickTest do
  use ExUnit.Case, async: true

  import Click.TestSupport.Html, only: [normalize: 1]

  alias Click.TestPlug

  setup do
    [browser: Click.new_browser()]
  end

  # todo: everything should return {:ok, _} or {:error, _}, including lists: {:ok, [_]}, {:error, [_]}
  #       maybe ! versions of all functions then that return something else

  test "can get the HTML source of a page", %{browser: browser} do
    html = browser |> Click.html()
    assert normalize(html) == normalize([TestPlug.home_page()])
  end

  test "can get text of an element", %{browser: browser} do
    header = browser |> Click.find_first("h1") |> Click.text()
    assert header == ["Hello, world!"]
  end

  test "can get text of multiple elements", %{browser: browser} do
    headers = browser |> Click.find_all("h2") |> Click.text()
    assert headers == ["Lorem", "Ipsum"]
  end
end
