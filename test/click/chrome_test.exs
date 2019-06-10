defmodule Click.ChromeTest do
  use ExUnit.Case, async: true

  alias Click.Chrome

  describe "result" do
    test "returns the result of the response" do
      assert Chrome.result({:ok, %{"result" => "foo"}}) == {:ok, "foo"}
    end

    test "can return a key from the result" do
      assert Chrome.result({:ok, %{"result" => %{"outerHTML" => "foo"}}}, "outerHTML") ==
               {:ok, "foo"}
    end
  end
end
