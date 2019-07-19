defmodule Click.Javascript do
  import Click.Ok, only: [ok!: 1]

  alias Click.Chrome
  alias Click.DomNode

  def visible?(%DomNode{} = node) do
    visible? = """
      return async function(element) {
        const ratio = await new Promise(resolve => {
          const observer = new IntersectionObserver(entries => {
            resolve(entries[0].intersectionRatio);
            observer.disconnect();
          });
          observer.observe(element);
        });

        return ratio > 0;
      }(this);
    """

    Chrome.call_function_on(node, visible?, await_promise: true) |> ok!()
  end
end
