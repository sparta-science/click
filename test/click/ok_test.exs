defmodule Click.OkTest do
  use ExUnit.Case, async: true

  import Click.Ok, only: [ok!: 1]

  describe "ok!" do
    test "with ok tuple" do
      assert {:ok, 1} |> ok!() == 1
    end

    test "with error tuple" do
      assert_raise RuntimeError, "Expected {:ok, _}, got: {:error, 1}", fn ->
        {:error, 1} |> ok!()
      end
    end

    test "with something that's not a tuple" do
      assert 1 |> ok!() == 1
    end

    test "with a list of okay tuples" do
      assert [{:ok, 1}, {:ok, 2}, {:ok, 3}] |> ok!() == [1, 2, 3]
    end

    test "with a list containing errors" do
      assert_raise RuntimeError, "Expected {:ok, _}, got: {:error, 2}", fn ->
        assert [{:ok, 1}, {:error, 2}, {:ok, 3}] |> ok!() == [1, 2, 3]
      end
    end

    test "with a list of things that are not tuples" do
      assert [1, 2, 3] |> ok!() == [1, 2, 3]
    end

    test "with a list of tuples and non-tuples" do
      assert [1, {:ok, 2}, 3] |> ok!() == [1, 2, 3]
    end
  end
end
