defmodule Click.Simulate do
  alias Click.Chrome
  alias Click.DomNode
  alias Click.Quad

  def click(%DomNode{} = node) do
    Chrome.scroll_into_view(node)

    # these coordinates are sometimes relative to something inside the page,
    # which makes this whole function click in the wrong place sometimes
    [x, y] = node |> Chrome.get_box_model() |> Quad.center()

    node
    |> Chrome.dispatch_mouse_event("mouseMoved", x, y, "none")
    |> Chrome.dispatch_mouse_event("mousePressed", x, y, "left")
    |> Chrome.dispatch_mouse_event("mouseReleased", x, y, "left")
  end

  def keypress(%DomNode{} = node, :enter) do
    # see https://github.com/GoogleChrome/puppeteer/blob/master/lib/USKeyboardLayout.js#L32
    # and https://github.com/GoogleChrome/puppeteer/blob/master/lib/Input.js#L176

    node
    |> Chrome.focus()
    |> Chrome.dispatch_key_event("keyDown", "Enter", 13, "Enter", "\r")
    |> Chrome.dispatch_key_event("keyUp", "Enter", 13, "Enter", "\r")
  end
end
