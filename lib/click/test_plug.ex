defmodule Click.TestPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case conn.request_path do
      "/" -> html(conn, home_page())
    end
  end

  defp html(conn, s) do
    conn |> put_resp_content_type("text/html") |> send_resp(200, s)
  end

  def home_page() do
    """
    <html>
      <head></head>
      <body>
        <h1>Hello, world!</h1>
        <h2>Lorem</h2>
        <h2>Ipsum</h2>
      </body>
    </html>
    """
  end
end
