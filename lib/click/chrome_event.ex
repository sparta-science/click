defmodule Click.ChromeEvent do
  alias ChromeRemoteInterface.PageSession
  alias Click.Browser

  @timeout 2_000
  @navigation_event "Page.frameNavigated"
  @content_event "Page.domContentEventFired"

  def flush(event) do
    receive do
      {:chrome_remote_interface, ^event, _response} -> flush(event)
    after
      0 -> :ok
    end
  end

  def subscribe(%Browser{pid: pid}, event) do
    :ok = PageSession.subscribe(pid, event)
  end

  def unsubscribe(%Browser{pid: pid}, event) do
    :ok = PageSession.unsubscribe(pid, event)
  end

  def wait_for_navigation(%Browser{} = browser, fun, success) do
    flush(@navigation_event)
    flush(@content_event)

    subscribe(browser, @navigation_event)
    subscribe(browser, @content_event)

    try do
      fun.()

      receive do
        {:chrome_remote_interface, @navigation_event, _response} ->
          receive do
            {:chrome_remote_interface, @content_event, _response} ->
              success.()
          after
            @timeout ->
              {:error, "timed out after #{@timeout}ms waiting for #{@content_event}"}
          end
      after
        @timeout ->
          {:error, "timed out after #{@timeout}ms waiting for #{@navigation_event}"}
      end
    after
      unsubscribe(browser, @navigation_event)
      unsubscribe(browser, @content_event)
    end
  end
end
