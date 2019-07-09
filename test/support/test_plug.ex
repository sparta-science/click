defmodule Click.TestSupport.TestPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    html(conn, load_page(conn.request_path, conn))
  end

  def load_page(path, conn \\ nil)

  def load_page("/", conn) do
    load_page("/home", conn)
  end

  def load_page("/info", conn) do
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

  def load_page("/" <> file, _conn) do
    File.read!("test/support/fixtures/#{file}.html")
  end

  defp html(conn, s) do
    conn |> put_resp_content_type("text/html") |> send_resp(200, s)
  end
end
