defmodule Click.ContextTest do
  use ExUnit.Case, async: true

  import Click.Assertions
  import Click.Context, only: [with_browser: 2, with_nodes: 2, with_one_node: 2]

  alias Click.Browser
  alias Click.DomNode

  describe "with_browser" do
    setup do
      fun = fn %Browser{pid: pid} -> pid end

      [fun: fun]
    end

    test "with browser, calls the function with the browser", %{fun: fun} do
      with_browser(%Browser{pid: 100}, fun)
      |> assert_eq(100)
    end

    test "with a tuple containing just the browser, calls the function with the browser", %{fun: fun} do
      with_browser({%Browser{pid: 100}}, fun)
      |> assert_eq(100)
    end

    test "with a tuple containng the browser and a node, calls the function with the browser", %{fun: fun} do
      with_browser({%Browser{pid: 100}, %DomNode{}}, fun)
      |> assert_eq(100)
    end

    test "with a tuple containing the browser and a list, calls the function with the browser", %{fun: fun} do
      with_browser({%Browser{pid: 100}, [%DomNode{}]}, fun)
      |> assert_eq(100)
    end
  end

  describe "with_nodes" do
    setup do
      browser = %Browser{}
      fun = fn {%Browser{} = _, %DomNode{id: id}} -> id end

      [browser: browser, fun: fun]
    end

    test "with browser, returns the browser", %{browser: browser, fun: fun} do
      with_nodes(browser, fun)
      |> assert_eq(browser)
    end

    test "with a tuple containing just the browser, returns the tuple", %{browser: browser, fun: fun} do
      with_nodes({browser}, fun)
      |> assert_eq({browser})
    end

    test "with a browser and a node, applies the function and returns result with the browser", %{browser: browser, fun: fun} do
      with_nodes({browser, %DomNode{id: 100}}, fun)
      |> assert_eq({browser, 100})
    end

    test "with a browser and a list of nodes, applies the function and returns the results with the browser", %{browser: browser, fun: fun} do
      with_nodes({browser, [%DomNode{id: 100}, %DomNode{id: 200}]}, fun)
      |> assert_eq({browser, [100, 200]})
    end
  end

  describe "with_one_node" do
    setup do
      browser = %Browser{}
      fun = fn {%Browser{} = _, %DomNode{id: id}} -> id end

      [browser: browser, fun: fun]
    end

    test "blows up when just a browser is passed in", %{browser: browser, fun: fun} do
      assert_raise FunctionClauseError, fn ->
        with_one_node(browser, fun)
      end
    end

    test "blows up when just a browser tuple is passed in", %{browser: browser, fun: fun} do
      assert_raise FunctionClauseError, fn ->
        with_one_node({browser}, fun)
      end
    end

    test "blows up when a browser and empty list is passed in", %{browser: browser, fun: fun} do
      assert_raise FunctionClauseError, fn ->
        with_one_node({browser, []}, fun)
      end
    end

    test "blows up when a browser and a multi-item list is passed in", %{browser: browser, fun: fun} do
      assert_raise FunctionClauseError, fn ->
        with_one_node({browser, [%DomNode{}, %DomNode{}]}, fun)
      end
    end

    test "calls the function when a browser and a node is passed in", %{browser: browser, fun: fun} do
      with_one_node({browser, %DomNode{id: 100_000}}, fun)
      |> assert_eq({browser, 100_000})
    end

    test "calls the function when a browser and a one-item list of nodes is passed in", %{browser: browser, fun: fun} do
      with_one_node({browser, [%DomNode{id: 100_000}]}, fun)
      |> assert_eq({browser, [100_000]})
    end
  end
end
