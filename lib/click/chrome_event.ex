defmodule Click.ChromeEvent do
  alias ChromeRemoteInterface.PageSession
  alias Click.DomNode

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

  def subscribe(%DomNode{pid: pid}, event) do
    :ok = PageSession.subscribe(pid, event)
  end

  def unsubscribe(%DomNode{pid: pid}, event) do
    :ok = PageSession.unsubscribe(pid, event)
  end

  def wait_for_navigation(%DomNode{} = node, fun, success) do
    flush(@navigation_event)
    flush(@content_event)

    subscribe(node, @navigation_event)
    subscribe(node, @content_event)

    try do
      fun.(node)

      receive do
        {:chrome_remote_interface, @navigation_event, _response} ->
          receive do
            {:chrome_remote_interface, @content_event, _response} ->
              success.(node)
          after
            @timeout ->
              {:error, "timed out after #{@timeout}ms waiting for #{@content_event}"}
          end
      after
        @timeout ->
          {:error, "timed out after #{@timeout}ms waiting for #{@navigation_event}"}
      end
    after
      unsubscribe(node, @navigation_event)
      unsubscribe(node, @content_event)
    end
  end
end
