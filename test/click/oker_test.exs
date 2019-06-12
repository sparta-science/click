defmodule Click.OkerTest do
  use ExUnit.Case, async: true

  alias Click.Oker

  describe "normalize" do
    test "ok tuples are unchanged" do
      assert Oker.normalize({:ok, "foo"}) == {:ok, "foo"}
    end

    test "error tuples are unchanged" do
      assert Oker.normalize({:error, "foo"}) == {:error, "foo"}
    end

    test "a list of ok tuples becomes an ok tuple with a list" do
      assert Oker.normalize([{:ok, 1}, {:ok, 2}]) == {:ok, [1, 2]}
    end

    test "a list of error tuples becomes an error tuple with a list" do
      assert Oker.normalize([{:error, 1}, {:error, 2}]) == {:error, [1, 2]}
    end

    test "a list of both ok and error tuples becomes an error tuple with a list" do
      assert Oker.normalize([{:ok, 1}, {:error, 2}]) == {:error, [1, 2]}
    end
  end
end
