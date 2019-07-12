defmodule Click.WaitUntil do
  def wait_until(fun, opts \\ []) when is_function(fun) and is_list(opts) do
    start_time = now_ms()

    try do
      fun.()
    rescue
      e -> process_error(fun, start_time, e, opts)
    end
  end

  def process_error(fun, start_time, error, opts) do
    timeout = Keyword.get(opts, :timeout, 500)

    if timeout > 0 do
      :timer.sleep(5)
      elapsed = now_ms() - start_time
      wait_until(fun, timeout: max(0, timeout - elapsed))
    else
      raise error
    end
  end

  def now_ms(), do: DateTime.utc_now() |> DateTime.to_unix(:millisecond)
end
