Supervisor.start_link([{Plug.Cowboy, scheme: :http, plug: Click.TestSupport.TestPlug, options: [port: 4001]}], strategy: :one_for_one)
ExUnit.start()
