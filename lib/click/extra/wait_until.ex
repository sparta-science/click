defmodule Click.Extra.WaitUntil do
  def wait_until(fun, opts \\ []) when is_function(fun) and is_list(opts) do
    start_time = now_ms()

    try do
      fun.()
    rescue
      e -> process_error(fun, start_time, e, opts)
    end
  end

  defp process_error(fun, start_time, error, opts) do
    timeout = Keyword.get(opts, :timeout, 500)
    expected_errors = Keyword.get(opts, :acceptable_errors, [])

    if error.__struct__ in expected_errors || expected_errors == [] do
      if timeout > 0 do
        :timer.sleep(5)
        elapsed = now_ms() - start_time
        wait_until(fun, timeout: max(0, timeout - elapsed), failure_fun: Keyword.get(opts, :failure_fun))
      else
        if Keyword.get(opts, :failure_fun) do
          Keyword.get(opts, :failure_fun).(error)
          raise error
        else
          raise error
        end
      end
    else
      raise error
    end
  end

  def now_ms(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
