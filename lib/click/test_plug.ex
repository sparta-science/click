defmodule Click.TestPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    case conn.request_path do
      "/" -> html(conn, home_page())
      "/attrs" -> html(conn, attrs_page())
      "/deep" -> html(conn, deep_page())
      "/info" -> html(conn, info_page(conn))
      "/links" -> html(conn, links_page(conn))
      "/page-two" -> html(conn, page_two())
    end
  end

  defp html(conn, s) do
    conn |> put_resp_content_type("text/html") |> send_resp(200, s)
  end

  def attrs_page() do
    """
    <html>
      <head></head>
      <body>
        <div class="topper" data-role="top" id="the-top">
          <div data-role="inner">inner</div>
        </div>
        <div data-role="bottom">second</div>
        <div>no data role</div>
      </body>
    """
  end

  def deep_page() do
    """
    <html>
      <head></head>
      <body>
        Hello.

        <div id="level-1">
          Start of level 1.

          <div id="level-2">
            Start of level 2.

            <div id="level-3">
              Level 3.
            </div>

            End of level 2.
          </div>

          End of level 1.
        </div>
      </body
    </html>
    """
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

  def links_page(conn) do
    """
    <html>
      <head></head>
      <body>
        <div><a id="page-two" href="/page-two">Page Two</a></div>
        <div style="height: 5000px">Tall content</div>
        <div><a id="home" href="/">Home</a></div>
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
