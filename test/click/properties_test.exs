defmodule Click.PropertiesTest do
  use ExUnit.Case, async: true

  import Click.Assertions

  @properties [
    %{
      "configurable" => true,
      "enumerable" => true,
      "isOwn" => true,
      "name" => "align",
      "value" => %{"type" => "string", "value" => ""},
      "writable" => false
    },
    %{
      "configurable" => true,
      "enumerable" => false,
      "isOwn" => false,
      "name" => "constructor",
      "value" => %{
        "className" => "Function",
        "description" => "function HTMLHeadingElement() { [native code] }",
        "objectId" => "{\"injectedScriptId\":1,\"id\":2}",
        "type" => "function"
      },
      "writable" => true
    },
    %{
      "configurable" => true,
      "enumerable" => false,
      "isOwn" => false,
      "name" => "Symbol(Symbol.toStringTag)",
      "symbol" => %{
        "description" => "Symbol(Symbol.toStringTag)",
        "objectId" => "{\"injectedScriptId\":1,\"id\":3}",
        "type" => "symbol"
      },
      "value" => %{"type" => "string", "value" => "HTMLHeadingElement"},
      "writable" => false
    },
    %{
      "configurable" => true,
      "enumerable" => true,
      "isOwn" => true,
      "name" => "innerText",
      "value" => %{"type" => "string", "value" => "Visible"},
      "writable" => false
    },
    %{
      "configurable" => true,
      "enumerable" => true,
      "isOwn" => true,
      "name" => "translate",
      "value" => %{"type" => "boolean", "value" => true},
      "writable" => false
    },
    %{
      "configurable" => true,
      "enumerable" => true,
      "isOwn" => true,
      "name" => "tabIndex",
      "value" => %{"description" => "-1", "type" => "number", "value" => -1},
      "writable" => false
    },
    %{
      "configurable" => true,
      "enumerable" => true,
      "isOwn" => true,
      "name" => "offsetParent",
      "value" => %{
        "className" => "HTMLBodyElement",
        "description" => "body",
        "objectId" => "{\"injectedScriptId\":1,\"id\":5}",
        "subtype" => "node",
        "type" => "object"
      },
      "writable" => false
    }
  ]

  describe "get" do
    import Click.Properties, only: [get: 2]

    test "gets a boolean",
      do: @properties |> get("translate") |> assert_eq(true)

    test "gets a function",
      do: @properties |> get("constructor") |> assert_eq("function HTMLHeadingElement() { [native code] }")

    test "gets a number",
      do: @properties |> get("tabIndex") |> assert_eq(-1)

    test "gets a object",
      do: @properties |> get("offsetParent") |> assert_eq("body")

    test "gets a string",
      do: @properties |> get("innerText") |> assert_eq("Visible")

    test "gets a symbol",
      do: @properties |> get("Symbol(Symbol.toStringTag)") |> assert_eq("HTMLHeadingElement")

    test "can get multiple properties at once",
      do: @properties |> get(["translate", "tabIndex"]) |> assert_eq([true, -1])
  end

  describe "get_all" do
    import Click.Properties, only: [get_all: 1]

    test "gets all the values" do
      @properties
      |> get_all()
      |> assert_eq(%{
        "Symbol(Symbol.toStringTag)" => "HTMLHeadingElement",
        "align" => "",
        "constructor" => "function HTMLHeadingElement() { [native code] }",
        "innerText" => "Visible",
        "offsetParent" => "body",
        "tabIndex" => -1,
        "translate" => true
      })
    end
  end
end
