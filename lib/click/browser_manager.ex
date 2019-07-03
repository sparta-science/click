defmodule Click.BrowserManager do
  use GenServer

  import ExUnit.Callbacks

  def start(args), do: start_supervised({__MODULE__, args}, restart: :temporary)
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(args) do
    wrapper_script = "#{Path.dirname(__ENV__.file)}/../../priv/stdin_watcher_wrapper"
    browser_path = Keyword.get(args, :browser_path)

    port =
      Port.open({:spawn_executable, wrapper_script}, [
        {:line, 100},
        :binary,
        :use_stdio,
        :exit_status,
        args: [
          browser_path,
          "--headless",
          "--remote-debugging-port=9222",
          "--window-size=1300x10000"
        ]
      ])

    {:ok, %{port: port, browser_path: browser_path}}
  end

  def handle_info(message, state) do
    IO.inspect(message, label: "message")
    IO.inspect(state, label: "state")
    {:noreply, state}
  end

  def terminate(reason, state) do
    IO.inspect(reason, label: "reason")
    IO.inspect(state, label: "state")
  end
end
