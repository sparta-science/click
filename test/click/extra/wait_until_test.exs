defmodule Click.Extra.WaitUntilTest do
  use ExUnit.Case, async: true

  alias Click.Extra.WaitUntil

  describe "wait_until" do
    test "when acceptable errors provided, loop only on acceptable errors" do
      test_fun = fn -> raise ArithmeticError end
      failure_fun = fn _e -> raise "failing in failure function" end

      assert_raise(RuntimeError, "failing in failure function", fn ->
        WaitUntil.wait_until(test_fun, timeout: 0, failure_fun: failure_fun, acceptable_errors: [ArithmeticError])
      end)
    end

    test "when acceptable errors provided, does not loop if an unacceptable error is raised" do
      test_fun = fn -> raise ArithmeticError end
      failure_fun = fn _e -> :failure_fun_called end

      assert_raise ArithmeticError, fn ->
        WaitUntil.wait_until(test_fun, timeout: 0, failure_fun: failure_fun, acceptable_errors: [RuntimeError])
      end
    end

    test "without acceptable errors, loop on any error" do
      test_fun = fn -> raise ArithmeticError end
      failure_fun = fn _e -> raise "failing in failure function" end

      assert_raise(RuntimeError, "failing in failure function", fn ->
        WaitUntil.wait_until(test_fun, timeout: 0, failure_fun: failure_fun)
      end)
    end

    test "keeps trying for some number of milliseconds, and then raises" do
      failing_fun = fn -> raise "failed!" end
      start_time = WaitUntil.now_ms()

      assert_raise RuntimeError, "failed!", fn ->
        WaitUntil.wait_until(failing_fun, timeout: 5)
      end

      end_time = WaitUntil.now_ms()
      assert end_time - start_time >= 5
    end

    test "returns the result of the function if it does not raise" do
      test_fun = fn -> :success end

      assert WaitUntil.wait_until(test_fun, timeout: 0) == :success
    end

    test "optionally calls a failure function, then raises the original error" do
      test_fun = fn -> raise "original failure" end
      failure_fun = fn _e -> :failure_fun end

      assert_raise(RuntimeError, "original failure", fn ->
        WaitUntil.wait_until(test_fun, timeout: 0, failure_fun: failure_fun, acceptable_errors: [RuntimeError])
      end)
    end
  end
end
