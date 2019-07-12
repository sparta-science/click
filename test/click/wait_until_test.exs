defmodule Click.WaitUntilTest do
  use ExUnit.Case, async: true

  alias Click.WaitUntil

  describe "wait_until" do
    test "loops on any error" do
      test_fun = fn -> raise ArithmeticError end

      assert_raise(ArithmeticError, fn ->
        WaitUntil.wait_until(test_fun, timeout: 0)
      end)
    end

    test "keeps trying for some number of milliseconds, and then raises" do
      test_fun = fn -> raise ArithmeticError end
      start_time = WaitUntil.now_ms()

      assert_raise ArithmeticError, fn ->
        WaitUntil.wait_until(test_fun, timeout: 5)
      end

      end_time = WaitUntil.now_ms()
      assert end_time - start_time >= 5
    end

    test "returns the result of the function if it does not raise" do
      test_fun = fn -> :success end

      assert WaitUntil.wait_until(test_fun, timeout: 0) == :success
    end
  end
end
