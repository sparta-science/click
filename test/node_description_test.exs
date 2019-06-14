defmodule Click.NodeDescriptionTest do
  use ExUnit.Case, async: true

  alias Click.NodeDescription

  @description %{
    "attributes" => ["id", "level-1"],
    "backendNodeId" => 3703,
    "childNodeCount" => 3,
    "children" => [
      %{
        "backendNodeId" => 3704,
        "localName" => "",
        "nodeId" => 0,
        "nodeName" => "#text",
        "nodeType" => 3,
        "nodeValue" => "\n      Level 1.\n\n      ",
        "parentId" => 0
      },
      %{
        "attributes" => ["id", "level-2"],
        "backendNodeId" => 3705,
        "childNodeCount" => 3,
        "children" => [
          %{
            "backendNodeId" => 3706,
            "localName" => "",
            "nodeId" => 0,
            "nodeName" => "#text",
            "nodeType" => 3,
            "nodeValue" => "\n        Start of level 2.\n\n        ",
            "parentId" => 0
          },
          %{
            "attributes" => ["id", "level-3"],
            "backendNodeId" => 3707,
            "childNodeCount" => 1,
            "children" => [
              %{
                "backendNodeId" => 3708,
                "localName" => "",
                "nodeId" => 0,
                "nodeName" => "#text",
                "nodeType" => 3,
                "nodeValue" => "\n          Level 3.\n        ",
                "parentId" => 0
              }
            ],
            "localName" => "div",
            "nodeId" => 0,
            "nodeName" => "DIV",
            "nodeType" => 1,
            "nodeValue" => "",
            "parentId" => 0
          },
          %{
            "backendNodeId" => 3709,
            "localName" => "",
            "nodeId" => 0,
            "nodeName" => "#text",
            "nodeType" => 3,
            "nodeValue" => "\n\n        End of level 2.\n      ",
            "parentId" => 0
          }
        ],
        "localName" => "div",
        "nodeId" => 0,
        "nodeName" => "DIV",
        "nodeType" => 1,
        "nodeValue" => "",
        "parentId" => 0
      },
      %{
        "backendNodeId" => 3710,
        "localName" => "",
        "nodeId" => 0,
        "nodeName" => "#text",
        "nodeType" => 3,
        "nodeValue" => "\n\n      End of level 1.\n    ",
        "parentId" => 0
      }
    ],
    "localName" => "div",
    "nodeId" => 0,
    "nodeName" => "DIV",
    "nodeType" => 1,
    "nodeValue" => ""
  }

  describe "extract_text" do
    test "extracts all the text" do
      text = NodeDescription.extract_text(@description)

      assert text == [
               "\n      Level 1.\n\n      ",
               "\n        Start of level 2.\n\n        ",
               "\n          Level 3.\n        ",
               "\n\n        End of level 2.\n      ",
               "\n\n      End of level 1.\n    "
             ]
    end
  end
end
