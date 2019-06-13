defmodule Click.TestPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case conn.request_path do
      "/" -> html(conn, home_page())
      "/info" -> html(conn, info_page(conn))
      "/page-two" -> html(conn, page_two())
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

  def info_page(conn) do
    user_agent = Plug.Conn.get_req_header(conn, "user-agent")

    """
    <html>
      <head></head>
      <body>
        <user-agent>#{user_agent}</user-agent>
      </body>
    </html>
    """
  end

  def page_two() do
    """
    <html>
      <head></head>
      <body>
        <h1>Page Two</h1>
      </body>
    </html>
    """
  end
end
