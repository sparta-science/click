defmodule Click.BrowserManager do
  use GenServer

  import ExUnit.Callbacks

  def start(args), do: start_supervised({__MODULE__, args}, restart: :temporary)
  def start_link(args), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(dashboard_port: dashboard_port) do
    wrapper_script = "#{Path.dirname(__ENV__.file)}/../../priv/stdin_watcher_wrapper"
    chromium_path = "/Applications/Chromium.app/Contents/MacOS/Chromium"

    port =
      Port.open({:spawn_executable, wrapper_script}, [
        {:line, 100},
        :binary,
        :use_stdio,
        :exit_status,
        args: [
          chromium_path,
          "--headless",
          "--remote-debugging-port=#{dashboard_port}",
          "--window-size=1300x10000"
        ]
      ])

    {:ok, port}
  end
end
