defmodule Click.Browser do
  import Click.Ok, only: [ok!: 1]

  defstruct ~w{base_url pid}a

  alias Click.Browser
  alias Click.BrowserSession
  alias Click.Chrome
  alias Click.ChromeEvent

  def new(base_url, opts \\ []) do
    with browser <- %Browser{base_url: base_url, pid: nil},
         {:ok, browser} <- BrowserSession.start(browser),
         :ok <- BrowserSession.update_user_agent(browser, Keyword.get(opts, :user_agent_suffix)) do
      {:ok, browser}
    end
  end

  def navigate(%Browser{} = browser, path) do
    ChromeEvent.wait_for_navigation(
      browser,
      fn -> Chrome.navigate(browser, path) |> ok!() end,
      fn -> Chrome.get_document(browser) end
    )
  end
end
