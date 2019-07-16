defmodule Click.Simulate do
  alias Click.Chrome
  alias Click.DomNode
  alias Click.Quad

  def click(%DomNode{} = node) do
    # the coordinates from get_box_model are sometimes relative to something inside the page,
    # which makes this whole function click in the wrong place sometimes

    with {:ok, node} <- Click.eval(node, "this.scrollIntoView()"),
         {:ok, box_model} <- Chrome.get_box_model(node),
         [x, y] <- box_model |> Quad.center(),
         {:ok, node} <- node |> Chrome.dispatch_mouse_event("mouseMoved", x, y, "none"),
         {:ok, node} <- node |> Chrome.dispatch_mouse_event("mousePressed", x, y, "left"),
         {:ok, node} <- node |> Chrome.dispatch_mouse_event("mouseReleased", x, y, "left") do
      {:ok, node}
    end
  end

  def keypress(%DomNode{} = node, :enter) do
    # see https://github.com/GoogleChrome/puppeteer/blob/master/lib/USKeyboardLayout.js#L32
    # and https://github.com/GoogleChrome/puppeteer/blob/master/lib/Input.js#L176

    with {:ok, node} <- node |> Chrome.focus(),
         {:ok, node} <- node |> Chrome.dispatch_key_event("keyDown", "Enter", 13, "Enter", "\r"),
         {:ok, node} <- node |> Chrome.dispatch_key_event("keyUp", "Enter", 13, "Enter", "\r") do
      {:ok, node}
    end
  end
end
